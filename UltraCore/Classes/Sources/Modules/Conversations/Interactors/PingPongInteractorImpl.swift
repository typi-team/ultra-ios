//
//  PingPongInteractorImpl.swift
//  UltraCore
//
//  Created by Slam on 1/7/24.
//

import RxSwift

class PingPongInteractorImpl: GRPCErrorUseCase<Void, Void> {
    
    override func job(params: Void) -> Single<Void> {
        Single.create { observer in
            let call = AppSettingsImpl.shared.updateService.ping(PingRequest(), callOptions: .default())
            
            call.response.whenComplete { result in
                switch result {
                case .success:
                    PP.info("Ping is success")
                    observer(.success(()))
                case let .failure(error):
                    PP.error("Ping is failure - \(error)")
                    observer(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
}
