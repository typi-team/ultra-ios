//
//  UpdateOnlineInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//
import RxSwift

class UpdateOnlineInteractor: GRPCErrorUseCase<Bool, UpdateStatusResponse> {
    
    override func job(params: Bool) -> Single<UpdateStatusResponse> {
        Single.create { observer -> Disposable in
            AppSettingsImpl.shared.userService.setStatus(.with({ $0.status = params ? .online : .away }), callOptions: .default()).response.whenComplete { result in
                switch result {
                case let .failure(error):
                    observer(.failure(error))
                case let .success(response):
                    observer(.success(response))
                }
            }

            return Disposables.create()
        }
    }
}
