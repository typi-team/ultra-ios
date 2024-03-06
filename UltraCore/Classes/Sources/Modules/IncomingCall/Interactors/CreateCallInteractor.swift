//
//  CreateCallInteractor.swift
//  UltraCore
//
//  Created by Typi on 05.03.2024.
//

import Foundation
import RxSwift

struct CreateCallRequestParams {
    let users: [String]
    let video: Bool
}

final class CreateCallInteractor: GRPCErrorUseCase<CreateCallRequestParams, CreateCallResponse> {
    private let callService: CallServiceClientProtocol
    
    init(callService: CallServiceClientProtocol) {
        self.callService = callService
    }
    
    override func job(params: CreateCallRequestParams) -> Single<CreateCallResponse> {
        return Single.create { [unowned self] single in
            let request = CreateCallRequest.with {
                $0.users = params.users
                $0.video = params.video
            }
            self.callService
                .create(request, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case .success(let response):
                        single(.success(response))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
