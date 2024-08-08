//
//  UpdateContactStatusInteractor.swift
//  UltraCore
//
//  Created by Typi on 12.04.2024.
//

import RxSwift

class UpdateContactStatusInteractor: GRPCErrorUseCase<String, Void> {
    final let contactDBService: ContactDBService
    
     init(contactDBService: ContactDBService) {
         self.contactDBService = contactDBService
    }
    
    override func job(params: String) -> Single<Void> {
        Single<GetContactStatusResponse>
            .create { [weak self] observer -> Disposable in
                guard let `self` = self else { return Disposables.create() }
                let request = GetContactStatusRequest.with { request in
                    request.userID = params
                }
                AppSettingsImpl.shared.contactsService.getContactStatus(request, callOptions: .default())
                    .response
                    .whenComplete { result in
                        switch result {
                        case let .success(response):
                            observer(.success(response))
                        case let .failure(error):
                            observer(.failure(error))
                        }
                    }

                return Disposables.create()
            }
            .flatMap { user -> Single<Void> in
                self.contactDBService.update(contacts: [user.status]).map({ _ in })
            }
    }
}
