//
//  ConversationsWireframe.swift
//  Pods
//
//  Created by Slam on 4/20/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class ConversationsWireframe: BaseWireframe<ConversationsViewController> {

    // MARK: - Private properties -
    fileprivate weak var delegate: UltraCoreSettingsDelegate?

    // MARK: - Module setup -

    init(appDelegate: UltraCoreSettingsDelegate?) {
        self.delegate = appDelegate
        let moduleViewController = ConversationsViewController()
        super.init(viewController: moduleViewController)

        let deleteConversationInteractor = DeleteConversationInteractor(conversationDBService: appSettings.conversationDBService,
                                                                        conversationService: appSettings.conversationService)
        
        let retrieveContactStatusesInteractor = RetrieveContactStatusesInteractor.init(contactDBService: appSettings.contactDBService,
                                                                                       contactService: appSettings.contactsService)
        let contactByUserIdInteractor = ContactByUserIdInteractor.init(delegate: UltraCoreSettings.delegate,
                                                                       contactsService: appSettings.contactsService)
        let messageSenderInteractor = SendMessageInteractor.init(messageService: appSettings.messageService)

        let contactToCreateChatByPhoneInteractor = ContactToCreateChatByPhoneInteractor.init(integrateService: appSettings.integrateService)
        let presenter = ConversationsPresenter(view: moduleViewController,
                                               updateRepository: appSettings.updateRepository,
                                               messageRepository: appSettings.messageRespository,
                                               contactDBService: appSettings.contactDBService,
                                               wireframe: self,
                                               conversationRepository: appSettings.conversationRespository,
                                               contactByUserIdInteractor: contactByUserIdInteractor,
                                               retrieveContactStatusesInteractor: retrieveContactStatusesInteractor,
                                               deleteConversationInteractor: deleteConversationInteractor, contactToCreateChatByPhoneInteractor: contactToCreateChatByPhoneInteractor,
                                               userStatusUpdateInteractor: UpdateOnlineInteractor(userService: appSettings.userService),
                                               messageSenderInteractor: messageSenderInteractor,
                                               mediaRepository: AppSettingsImpl.shared.mediaRepository)
        moduleViewController.presenter = presenter
    }
}

// MARK: - Extensions -

extension ConversationsWireframe: ConversationsWireframeInterface {
    func navigateToContacts(contactsCallback: @escaping ContactsCallback, openConverationCallback: @escaping UserIDCallback) {
        if let contactsViewController = self.delegate?.contactsViewController(contactsCallback: contactsCallback,
                                                                              openConverationCallback: openConverationCallback) {
            self.navigationController?.pushViewController(contactsViewController, animated: true)
        } else {
            self.navigationController?.presentWireframeWithNavigation(ContactsBookWireframe(contactsCallback: contactsCallback, openConversationCallback: openConverationCallback))
        }
    }
    
    func navigateToConversation(with data: Conversation) {
        self.navigationController?.pushWireframe(ConversationWireframe(with: data))
    }
}
