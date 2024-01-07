//
//  PingPongInteractorImpl.swift
//  UltraCore
//
//  Created by Slam on 1/7/24.
//

import RxSwift

class PingPongInteractorImpl: GRPCErrorUseCase<Void, Void> {
    fileprivate let updateClient: UpdatesServiceClientProtocol
    
    init( updateClient: UpdatesServiceClientProtocol) {
        self.updateClient = updateClient
    }
    
    override func job(params: Void) -> Single<Void> {
        Single.create { observer in
            let call = self.updateClient.ping(PingRequest(), callOptions: .default())

            call.response.whenComplete { result in
                    switch result {
                    case .success:
                        observer(.success(()))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
}
