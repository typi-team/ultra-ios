//
//  CreateFileInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/5/23.
//

import RxSwift


class CreateFileInteractor: UseCase<(data: Data, extens: String), [FileChunk]> {

     private let fileService: FileServiceClientProtocol

     init(fileService: FileServiceClientProtocol) {
         self.fileService = fileService
     }

    override func executeSingle(params: (data: Data, extens: String)) -> Single<[FileChunk]> {
        return Single.create { [weak self] observer -> Disposable in
            do {
                guard let `self` = self else { return Disposables.create() }
                let request = FileCreateRequest.with({
                    $0.name = params.data.hashValue.description
                    $0.size = Int64(params.data.count)
                    $0.mimeType = "image/\(params.extens)"
                })

                try self.writeDataToFile(data: params.data, fileName: request.name)

                self.fileService.create(request, callOptions: .default())
                    .response
                    .whenComplete { [weak self] result in
                        guard let `self` = self else { return observer(.failure(NSError.selfIsNill)) }
                        switch result {
                        case let .success(response):
                            observer(.success(splitDataIntoChunks(data: params.data, file: response)))
                        case let .failure(error):
                            observer(.failure(error))
                        }
                    }
            } catch let error {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
}

private extension CreateFileInteractor {
    func splitDataIntoChunks(data: Data, file response: FileCreateResponse ) -> [FileChunk] {
        var chunks: [FileChunk] = []
        var offset = 0
        
        var seqNumber: Int64 = 0
        
        while offset < data.count {
            let chunkLength = min(Int(response.chunkSize), data.count - offset)
            let chunkRange = Range(offset..<offset + chunkLength)
            let chunkData = data.subdata(in: chunkRange)
            chunks.append(FileChunk.with({ file in
                file.fileID = response.fileID
                file.data = chunkData
                file.seqNum = seqNumber
                
            }))
            seqNumber += 1
            offset += chunkLength
        }
        
        return chunks
    }
    
    func writeDataToFile(data: Data, fileName: String) throws {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "Ошибка получения директории документов", code: 1001)
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }
}

class UploadFileInteractor: UseCase<[FileChunk], FileChunk> {

     private let fileService: FileServiceClientProtocol

     init(fileService: FileServiceClientProtocol) {
         self.fileService = fileService
     }

     override func execute(params: [FileChunk]) -> Observable<FileChunk> {
         return Observable.from(params).flatMap { file -> Observable<FileChunk> in
             return Observable<FileChunk>.create { observer -> Disposable in
                 self.fileService.upload(callOptions: .default())
                     .sendMessage(file)
                     .whenComplete { result in
                     switch result {
                     case .success:
                         observer.on(.next(file))
                     case let .failure(error):
                         observer.on(.error(error))
                     }
                 }
                 return Disposables.create()
             }
         }
     }
}
