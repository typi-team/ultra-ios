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
                .whenComplete {[weak self] result in
                    
                    switch result {
                    case let .success(userByContact):
                        if userByContact.hasUser {
                            let info = self?.delegate?.info(from: userByContact.user.phone)
                            observer(.success(.with({
                                $0.userID = userByContact.user.id
                                $0.phone = userByContact.user.phone
                                $0.photo = userByContact.user.photo
                                $0.lastname = info?.lastname ?? userByContact.user.lastname
                                $0.firstname = info?.firstname ?? userByContact.user.firstname
                            })))
                        } else if userByContact.hasContact {
                            observer(.success(.with({
                                let info = self?.delegate?.info(from: userByContact.contact.phone)
                                $0.phone = userByContact.contact.phone
                                $0.photo = userByContact.contact.photo
                                $0.userID = userByContact.contact.userID
                                $0.lastname = info?.lastname ?? userByContact.contact.lastname
                                $0.firstname = info?.firstname ?? userByContact.contact.firstname
                            })))
                        } else {
                            observer(.failure(NSError.objectsIsNill))
                        }
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
