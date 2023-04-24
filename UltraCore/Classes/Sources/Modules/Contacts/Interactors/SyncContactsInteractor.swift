//
//  SyncContactsInteractor.swift
//  UltraCore
//
//  Created by Slam on 4/24/23.
//
import RxSwift
import Foundation

class SyncContactsInteractor: UseCase<ContactRequest, ContactResponse> {
    fileprivate let contactsService: ContactServiceClientProtocol
    
    init(contactsService: ContactServiceClientProtocol) {
        self.contactsService = contactsService
    }
    
    override func executeSingle(params: ContactRequest) -> Single<ContactResponse> {
        return Single.create { observer -> Disposable in
            self.contactsService.insertContacts(params,callOptions:  .default())
                .response
                .whenComplete { result in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
}
