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
    
    init(delegate: UltraCoreSettingsDelegate?) {
        self.delegate = delegate
    }
        
    override func job(params: String) -> Single<ContactDisplayable> {
        PP.debug("Starting to get contact by ID - \(params)")
        return Single<ContactDisplayable>.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            let requestParam = ContactByUserIdRequest.with({ $0.userID = params })
            AppSettingsImpl.shared.contactsService.getContactByUserId(requestParam, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case let .success(userByContact):
                        PP.debug("Successfully received a contact")
                        let photo = userByContact.contact.hasPhoto ? userByContact.contact.photo : userByContact.user.photo
                        let lastname = userByContact.hasContact ? userByContact.contact.lastname : userByContact.user.lastname
                        let firstname = userByContact.hasContact ? userByContact.contact.firstname : userByContact.user.firstname
                        let phone = userByContact.hasContact ? userByContact.contact.phone : userByContact.user.phone
                        let status = userByContact.contact.status

                        observer(.success(ContactDisplayableImpl(contact: .with({ contact in
                            contact.phone = phone
                            contact.photo = photo
                            contact.userID = params
                            contact.lastname = lastname
                            contact.firstname = firstname
                            if status.lastSeen != 0 {
                                contact.status = status
                            }
                            contact.isBlocked = userByContact.hasContact ? userByContact.contact.isBlocked : userByContact.user.isBlocked
                        }))))
                    case let .failure(error):
                        PP.error("Failed to get contact with ID - \(params); error - \(error.localeError)")
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
