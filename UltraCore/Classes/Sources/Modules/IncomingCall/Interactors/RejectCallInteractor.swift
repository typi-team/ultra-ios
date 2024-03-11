//
//  RejectCallInteractor.swift
//  UltraCore
//
//  Created by Typi on 05.03.2024.
//

import Foundation
import RxSwift

final class RejectCallInteractor: GRPCErrorUseCase<CallerRequestParams, Void> {
    private let callService: CallServiceClientProtocol
    
    init(callService: CallServiceClientProtocol) {
        self.callService = callService
    }
    
    override func job(params: CallerRequestParams) -> Single<Void> {
        Single.create { [unowned self] single in
            let request = RejectCallRequest.with {
                $0.callerUserID = params.userID
                $0.room = params.room
            }
            self.callService
                .reject(request, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case .success(let response):
                        single(.success(()))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
