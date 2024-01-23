//
//  UpdateTokenInteractorImpl.swift
//  UltraCore
//
//  Created by Slam on 1/3/24.
//

import RxSwift

class UpdateTokenInteractorImpl: UseCase<Void, Void> {

    final let authService: AuthServiceClientProtocol
    final let appStore: AppSettingsStore
    final weak var delegate: UltraCoreSettingsDelegate?

    init(appStore: AppSettingsStore,
         authService: AuthServiceClientProtocol,
         delegate: UltraCoreSettingsDelegate? = UltraCoreSettings.delegate) {
        self.appStore = appStore
        self.delegate = delegate
        self.authService = authService
    }

    override func executeSingle(params: Void) -> Single<Void> {
        return Single<String>.create { [weak self] observer -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }

            if let delegate = self.delegate {
                delegate.token { result in
                    switch result {
                    case .success(let token):
                        observer(.success(token))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            } else {
                observer(.failure(NSError.objectsIsNill))
            }

            return Disposables.create()
        }
        .flatMap({ self.updateToken(params: $0) }).map { _ in () }
    }
    
    private func updateToken(params: String) -> Single<IssueJwtResponse> {
        return Single.create { [weak self] observer -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            let call = self.authService.issueJwt(.with({
                $0.device = .ios
                $0.sessionID = params
                $0.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Ну указано"
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

