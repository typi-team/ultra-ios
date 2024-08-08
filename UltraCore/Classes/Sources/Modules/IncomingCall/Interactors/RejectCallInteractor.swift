//
//  RejectCallInteractor.swift
//  UltraCore
//
//  Created by Typi on 05.03.2024.
//

import Foundation
import RxSwift

final class RejectCallInteractor: GRPCErrorUseCase<CallerRequestParams, Void> {
    
    override func job(params: CallerRequestParams) -> Single<Void> {
        Single.create { single in
            let request = RejectCallRequest.with {
                $0.callerUserID = params.userID
                $0.room = params.room
            }
            AppSettingsImpl.shared.callService
                .reject(request, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case .success:
                        single(.success(()))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
