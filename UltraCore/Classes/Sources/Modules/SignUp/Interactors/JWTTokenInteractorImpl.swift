//
//  JWTTokenInteractorImpl.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation
import RxSwift
import GRPC

class JWTTokenInteractorImpl: UseCase<String, IssueJwtResponse> {

    final let authService: AuthServiceClientProtocol
    final let appStore: AppSettingsStore

    init(appStore: AppSettingsStore,
         authService: AuthServiceClientProtocol) {
        self.appStore = appStore
        self.authService = authService
    }

    override func executeSingle(params: String) -> Single<IssueJwtResponse> {
        return Single.create { [weak self] observer -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            let call = self.authService.issueJwt(.with({
                $0.device = .ios
                $0.sessionID = params
                $0.deviceID = self.appStore.deviceID()
            }), callOptions: .default())

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
        .do(onSuccess: { [weak self] response in
            guard let `self` = self else { return }
            self.appStore.store(token: response.token)
            self.appStore.store(userID: response.userID)
        })
    }
}
