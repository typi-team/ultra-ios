//
//  ContactByUserIdInteractor.swift
//  UltraCore
//
//  Created by Slam on 5/4/23.
//
import RxSwift
import Foundation

class ContactByUserIdInteractor: GRPCErrorUseCase<String, ContactDisplayable> {
    
    fileprivate weak var  delegate: UltraCoreSettingsDelegate?
    
    fileprivate let contactsService: ContactServiceClientProtocol
    
    
    init(delegate: UltraCoreSettingsDelegate?,
         contactsService: ContactServiceClientProtocol) {
        self.contactsService = contactsService
        self.delegate = delegate
    }
        
    override func job(params: String) -> Single<ContactDisplayable> {
        Single<ContactDisplayable>.create { [weak self] observer -> Disposable in
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
                        let phone = userByContact.hasContact ? userByContact.contact.phone : userByContact.user.phone

                        observer(.success(ContactDisplayableImpl(contact: .with({ contact in
                            contact.phone = phone
                            contact.photo = photo
                            contact.userID = params
                            contact.lastname = lastname
                            contact.firstname = firstname
                            contact.isBlocked = userByContact.hasContact ? userByContact.contact.isBlocked : userByContact.user.isBlocked
                        }))))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
