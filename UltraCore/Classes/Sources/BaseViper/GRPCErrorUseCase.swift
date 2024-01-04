//
//  GRPCErrorUseCase.swift
//  UltraCore
//
//  Created by Slam on 1/3/24.
//

import Foundation
import RxSwift

public typealias StringCallback = (String?) -> Void

class GRPCErrorUseCase<P, R> {
    final let updateTokenInteractor: UseCase<Void, Void> = AppSettingsImpl.shared.updateTokenInteractor
    
    func executeSingle(params: P) -> Single<R> {
        return self.job(params: params)
            .catch({ error -> Single<R> in
                return self.handleGRPC(error: error)
                    .flatMap({self.job(params: params)})
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
