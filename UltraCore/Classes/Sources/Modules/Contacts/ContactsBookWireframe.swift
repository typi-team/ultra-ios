//
//  ContactsBookWireframe.swift
//  Pods
//
//  Created by Slam on 4/21/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class ContactsBookWireframe: BaseWireframe<ContactsBookViewController> {

    // MARK: - Private properties -

    // MARK: - Module setup -

    init() {
        let moduleViewController = ContactsBookViewController()
        super.init(viewController: moduleViewController)
        
        let syncInteractor = SyncContactsInteractor.init(contactsService: appSettings.contactsService)
        let presenter = ContactsBookPresenter(view: moduleViewController, contactsRepository: appSettings.contactRepository,
                                              wireframe: self,
                                              syncContact: syncInteractor,
                                              bookContacts: ContactsBookInteractor())
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension ContactsBookWireframe: ContactsBookWireframeInterface {
    func openConversation(with contact: ContactDisplayable) {
        self.navigationController?.pushWireframe(ConversationWireframe(with: ConversationImpl(contact: contact)))
    }
}
