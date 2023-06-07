//
//  UploadFileInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import RxSwift

class UploadFileInteractor: UseCase<[FileChunk], FileChunk> {

     private let fileService: FileServiceClientProtocol

     init(fileService: FileServiceClientProtocol) {
         self.fileService = fileService
     }

     override func execute(params: [FileChunk]) -> Observable<FileChunk> {
         return Observable<FileChunk>.create { observer -> Disposable in
             var call = self.fileService.upload(callOptions: .default())
             
                 call.sendMessages(params, compression: .enabled)
                    .whenComplete { result in
                        
                        switch result {
                        case .success:
                            call.sendEnd().whenSuccess { _ in
                                observer.on(.next(params.last!))
                            }
                            
                            
                        case let .failure(error):
                            observer.on(.error(error))
                        }
                    }
             return Disposables.create()
         }
     }
}
