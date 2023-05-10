//
//  ContactsBookPresenter.swift
//  Pods
//
//  Created by Slam on 4/21/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//
import RxSwift
import RealmSwift
import Foundation

final class ContactsBookPresenter: BasePresenter {
    
    // MARK: - Public properties -

    lazy var contacts: Observable<Results<DBContact>> = contactsRepository.contacts()

    // MARK: - Private properties -

    fileprivate let disposeBag = DisposeBag()
    fileprivate unowned let view: ContactsBookViewInterface
    fileprivate let wireframe: ContactsBookWireframeInterface
    fileprivate let syncContact: UseCase<ContactsImportRequest, ContactImportResponse>
    fileprivate let bookContacts: UseCase<Void, ContactsBookInteractor.Contacts>
    fileprivate let contactsRepository: ContactsRepository
    // MARK: - Lifecycle -

    init(view: ContactsBookViewInterface,
         contactsRepository: ContactsRepository,
         wireframe: ContactsBookWireframeInterface,
         syncContact: UseCase<ContactsImportRequest, ContactImportResponse>,
         bookContacts: UseCase<Void, ContactsBookInteractor.Contacts>) {
        self.view = view
        self.wireframe = wireframe
        self.syncContact = syncContact
        self.bookContacts = bookContacts
        self.contactsRepository = contactsRepository
    }
}

// MARK: - Extensions -

extension ContactsBookPresenter: ContactsBookPresenterInterface {
    func openConversation(with contact: DBContact) {
        self.wireframe.openConversation(with: contact)
    }
    
     
    func initial() {
        self.bookContacts
            .executeSingle(params: ())
            .flatMap({[weak self] result -> Single<ContactImportResponse> in
                guard let `self` = self else { throw NSError.selfIsNill}
                var request = ContactsImportRequest()
                request.contacts = result.contacts
                return self.syncContact.executeSingle(params: request)
            })
            .flatMap({ [weak self] response -> Single<Void> in
                guard let `self` = self else { throw NSError.selfIsNill}
                return self.contactsRepository.save(contacts: response)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { Logger.info("Contacts saved on db") })
            .disposed(by: self.disposeBag)
    }
}
