//
//  UploadFileInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import RxSwift

class UploadFileInteractor: GRPCErrorUseCase<[FileChunk], Void> {

     private let fileService: FileServiceClientProtocol

     init(fileService: FileServiceClientProtocol) {
         self.fileService = fileService
     }

    override func job(params: [FileChunk]) -> Single<Void> {
        Observable.from(params)
            .concatMap({self.upload(chunk: $0)})
            .toArray()
            .map({_ in ()})
    }
    
    private func upload(chunk: FileChunk) -> Single<Void> {
        Single<Void>.create { [weak self ] observer -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            
            self.fileService.uploadChunks(.with({
                $0.fileID = chunk.fileID
                $0.chunks = [chunk]
            }), callOptions: .default())
                .response
                .whenComplete({ result in
                    switch result {
                    case .success:
                        observer(.success(()))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                })

            return Disposables.create()
        }
    }
}
