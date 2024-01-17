//
//  SignUpInteractorImpl.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation
import RxSwift
import GRPC
import NIOCore
import Logging

class UserIdInteractorImpl: UseCase<GetUserIdRequest, GetUserIdResponse> {
  final let authService: AuthServiceClientProtocol

    init(authService: AuthServiceClientProtocol) {
        self.authService = authService
    }
    
    override func executeSingle(params: GetUserIdRequest) -> Single<GetUserIdResponse> {
        return Single.create { [weak self] observer -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            let call = self.authService.getUserId(params,callOptions: CallOptions.default() )
            call.response.whenComplete { result in
                switch result {
                case let .failure(error):
                    observer(.failure(error))
                case let .success(value):
                    observer(.success(value))
                }
            }

            return Disposables.create()
        }
    }
}


extension CallOptions {
    static func `default`(include timeout: Bool = true) -> CallOptions {
        var logger = Logger(label: "com.typi.ultra")
        logger.logLevel = .warning

        if let token = AppSettingsImpl.shared.appStore.token {
            return .init(customMetadata: .init(httpHeaders: ["Authorization": "Bearer \(token)"]),
                         timeLimit: timeout ? .timeout(.seconds(20)) : .none,
                         logger: logger)
        } else {
            PP.error("Called default() when token is nill")
            return .init(timeLimit: timeout ? .timeout(.seconds(20)) : .none, logger: logger)
        }
    }
}


