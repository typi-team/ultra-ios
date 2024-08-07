//
//  CancelCallInteractor.swift
//  UltraCore
//
//  Created by Typi on 05.03.2024.
//

import Foundation
import RxSwift

struct CallerRequestParams {
    let userID: String
    let room: String
}

final class CancelCallInteractor: GRPCErrorUseCase<CallerRequestParams, Void> {

    override func job(params: CallerRequestParams) -> Single<Void> {
        Single.create { single -> Disposable in
            let request = CancelCallRequest.with({
                $0.userID = params.userID
                $0.room = params.room
            })
            AppSettingsImpl.shared.callService
                .cancel(request, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case let .success(response):
                        single(.success(()))
                    case let .failure(error):
                        single(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
