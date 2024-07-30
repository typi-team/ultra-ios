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

    final let appStore: AppSettingsStore

    init(appStore: AppSettingsStore) {
        self.appStore = appStore
    }

    override func executeSingle(params: String) -> Single<IssueJwtResponse> {
        return Single.create { observer -> Disposable in
            let call = AppSettingsImpl.shared.authService.issueJwt(.with({
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
