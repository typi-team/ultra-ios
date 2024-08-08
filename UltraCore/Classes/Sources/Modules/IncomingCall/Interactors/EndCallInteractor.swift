//
//  EndCallInteractor.swift
//  UltraCore
//
//  Created by Typi on 26.06.2024.
//

import Foundation
import RxSwift

struct EndCallParams {
    let room: String
}

final class EndCallInteractor: GRPCErrorUseCase<EndCallParams, Void> {

    override func job(params: EndCallParams) -> Single<Void> {
        Single.create { single in
            let request = CallEndRequest.with {
                $0.room = params.room
            }
            AppSettingsImpl.shared.callService
                .end(request, callOptions: .default())
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
