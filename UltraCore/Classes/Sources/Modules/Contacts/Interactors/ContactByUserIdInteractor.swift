//
//  ContactByUserIdInteractor.swift
//  UltraCore
//
//  Created by Slam on 5/4/23.
//
import RxSwift
import Foundation

class ContactByUserIdInteractor: UseCase<String, Contact> {
    fileprivate let contactsService: ContactServiceClientProtocol
    
    
    init(contactsService: ContactServiceClientProtocol) {
        self.contactsService = contactsService
    }
        
    override func executeSingle(params: String) -> Single<Contact> {
        return Single.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            let requestParam = ContactByUserIdRequest.with({ $0.userID = params })
            self.contactsService.getContactByUserId(requestParam, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case let .success(userByContact):
                        observer(.success(userByContact.contact))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }

            return Disposables.create()
        }
    }
}
