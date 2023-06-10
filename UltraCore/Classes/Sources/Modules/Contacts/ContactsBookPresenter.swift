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

    lazy var contacts: Observable<[Contact]> = contactsRepository.contacts()

    // MARK: - Private properties -

    fileprivate let disposeBag = DisposeBag()
    fileprivate let contactsRepository: ContactsRepository
    fileprivate unowned let view: ContactsBookViewInterface
    fileprivate let wireframe: ContactsBookWireframeInterface
//    fileprivate let fileDownloadService: UseCase<PhotoDownloadRequest, Any>
    fileprivate let bookContacts: UseCase<Void, ContactsBookInteractor.Contacts>
    fileprivate let syncContact: UseCase<ContactsImportRequest, ContactImportResponse>
    
    // MARK: - Lifecycle -

    init(view: ContactsBookViewInterface,
         contactsRepository: ContactsRepository,
         wireframe: ContactsBookWireframeInterface,
//         fileDownloadService: UseCase<PhotoDownloadRequest, Any>,
         syncContact: UseCase<ContactsImportRequest, ContactImportResponse>,
         bookContacts: UseCase<Void, ContactsBookInteractor.Contacts>) {
        self.view = view
        self.wireframe = wireframe
        self.syncContact = syncContact
        self.bookContacts = bookContacts
        self.contactsRepository = contactsRepository
//        self.fileDownloadService = fileDownloadService
    }
}

// MARK: - Extensions -

extension ContactsBookPresenter: ContactsBookPresenterInterface {
    func openConversation(with contact: ContactDisplayable) {
        self.wireframe.openConversation(with: contact)
    }
    
    func initial() {
        self.bookContacts
            .executeSingle(params: ())
            .flatMap({ [weak self] result -> Single<ContactImportResponse> in
                guard let `self` = self else { throw NSError.selfIsNill }
                if result.contacts.isEmpty {
                    return Single.just(ContactImportResponse())
                }
                var request = ContactsImportRequest()
                request.contacts = result.contacts
                return self.syncContact.executeSingle(params: request)
            })
            .do(onSuccess: { [weak self] result in
                guard let `self` = self else { throw NSError.selfIsNill }
                self.runDownloadingImage(for: result.contacts)
            })
            .flatMap({ [weak self] response -> Single<[Contact]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.contactsRepository.save(contacts: response).map({ response.contacts })
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { contacts in PP.info("Contacts \(contacts.count)pcs saved on db") })
            .disposed(by: self.disposeBag)
    }
    
    func runDownloadingImage(for contacts: [Contact]) {
        
        
    }
}
