//
//  FileDonwloadInteractor.swift
//  UltraCore
//
//  Created by Slam on 5/24/23.
//

import RxSwift
import Foundation

class ImageDownloadInteractor: UseCase<PhotoDownloadRequest, Any> {
    fileprivate let client: FileServiceClientProtocol
    
    init(client: FileServiceClientProtocol) {
        self.client = client
    }
    
    override func executeSingle(params: PhotoDownloadRequest) -> Single<Any> {
        return Single.create {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create()}
            
            self.client.downloadPhoto(params, callOptions: .default()) { chunk in
                observer(.success(chunk.data))
            }.status.whenComplete { result in
                switch result {
                case let .success(status):
                    observer(.success(status.isOk))
                case let .failure(error):
                    observer(.failure(error))
                }
            }
            return Disposables.create()
            
        }
    }
}
