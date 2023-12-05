//
//  RetrieveContactStatusesInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//

import RxSwift

class RetrieveContactStatusesInteractor: UseCase<Void, Void> {
    final let contactDBService: ContactDBService
    final let contactService: ContactServiceClientProtocol
    
     init(contactDBService: ContactDBService,
          contactService: ContactServiceClientProtocol) {
         self.contactService = contactService
         self.contactDBService = contactDBService
    }
    
    override func execute(params: Void) -> Observable<Void> {
        return Single<GetStatusesResponse>
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
            .asObservable()
            .flatMap { user -> Observable<Void> in
                return Observable<UserStatus>
                    .from(user.statuses)
                    .flatMap { status -> Single<Void> in
                        return self.contactDBService.update(contact: status).map({_ in })
                    }
            }
    }

}
