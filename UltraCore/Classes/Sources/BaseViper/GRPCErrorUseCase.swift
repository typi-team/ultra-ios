//
//  GRPCErrorUseCase.swift
//  UltraCore
//
//  Created by Slam on 1/3/24.
//

import Foundation
import RxSwift
import GRPC

public typealias StringCallback = (String?) -> Void

class GRPCErrorUseCase<P, R> {
    final let updateTokenInteractor: UseCase<Void, Void> = AppSettingsImpl.shared.updateTokenInteractor
    
    func executeSingle(params: P) -> Single<R> {
        self.job(params: params)
            .catch({ error -> Single<R> in
                if (error as? GRPC.GRPCStatus)?.code == .unauthenticated {
                    return self.handleGRPC(error: error)
                        .flatMap({ self.job(params: params) })
                } else {
                    return Single.error(error)
                }
            })
    }
    
    func job(params: P) -> Single<R> {
        fatalError("job(params:) has not been implemented")
    }
    
    private func handleGRPC(error: Error) -> Single<Void> {
        self.updateTokenInteractor.executeSingle(params: ())
    }

    deinit {
        PP.info("Deinit \(String.init(describing: self))")
    }
}
