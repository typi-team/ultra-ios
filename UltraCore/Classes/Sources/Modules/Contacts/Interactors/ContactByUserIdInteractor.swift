//
//  ContactByUserIdInteractor.swift
//  UltraCore
//
//  Created by Slam on 5/4/23.
//
import RxSwift
import Foundation

class ContactByUserIdInteractor: UseCase<String, Contact> {
    
    fileprivate weak var  delegate: UltraCoreSettingsDelegate?
    
    fileprivate let contactsService: ContactServiceClientProtocol
    
    
    init(delegate: UltraCoreSettingsDelegate?,
         contactsService: ContactServiceClientProtocol) {
        self.contactsService = contactsService
        self.delegate = delegate
    }
        
    override func executeSingle(params: String) -> Single<Contact> {
        return Single<Contact>.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            let requestParam = ContactByUserIdRequest.with({ $0.userID = params })
            self.contactsService.getContactByUserId(requestParam, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case let .success(userByContact):
                        
                        let photo = userByContact.contact.hasPhoto ? userByContact.contact.photo : userByContact.user.photo
                        let lastname = userByContact.hasContact ? userByContact.contact.lastname : userByContact.user.lastname
                        let firstname = userByContact.hasContact ? userByContact.contact.firstname : userByContact.user.firstname

                        observer(.success(.with({ contact in
                            contact.photo = photo
                            contact.userID = params
                            contact.lastname = lastname
                            contact.firstname = firstname
                        })))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
