//
//  RetrieveContactStatusesInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//

import RxSwift

class RetrieveContactStatusesInteractor: GRPCErrorUseCase<Void, Void> {
    final let contactDBService: ContactDBService
    final let contactService: ContactServiceClientProtocol
    
     init(contactDBService: ContactDBService,
          contactService: ContactServiceClientProtocol) {
         self.contactService = contactService
         self.contactDBService = contactDBService
    }
    
    override func job(params: Void) -> Single<Void> {
        Single<GetStatusesResponse>
            .create { [weak self] observer -> Disposable in
                guard let `self` = self else { return Disposables.create() }
                self.contactService.getStatuses(.init(), callOptions: .default())
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
                self.contactDBService.update(contacts: user.statuses).map({ _ in })
            }
    }

}
