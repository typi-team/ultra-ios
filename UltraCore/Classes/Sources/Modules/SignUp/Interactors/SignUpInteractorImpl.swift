//
//  SignUpInteractorImpl.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation
import RxSwift
import GRPC

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
            let call = self.authService.getUserId(params)
            call.response.whenComplete { result in
                switch result {
                case let .failure(error):
                    observer(.failure(error))
                case let .success(value):
                    observer(.success(value))
                }
            }

            return Disposables.create {
                call.cancel(promise: nil)
            }
        }
    }
}

