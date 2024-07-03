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

    init(appDelegate: UltraCoreSettingsDelegate?, isSupport: Bool) {
        self.delegate = appDelegate
        let moduleViewController = ConversationsViewController()
        super.init(viewController: moduleViewController)

        let deleteConversationInteractor = DeleteConversationInteractor(conversationDBService: appSettings.conversationDBService,
                                                                        conversationService: appSettings.conversationService)
        
        let contactByUserIdInteractor = ContactByUserIdInteractor.init(delegate: UltraCoreSettings.delegate,
                                                                       contactsService: appSettings.contactsService)
        
        let contactToConversationInteractor = ContactToConversationInteractor.init(contactDBService: appSettings.contactDBService,
                                                                                   contactsService: appSettings.contactsService,
                                                                                   integrateService: appSettings.integrateService)
        
        let messageSenderInteractor = SendMessageInteractor.init(messageService: appSettings.messageService)

        let resendMessagesInteractor = ResendingMessagesInteractor(messageRepository: appSettings.messageRespository, mediaRepository: appSettings.mediaRepository, messageSenderInteractor: messageSenderInteractor)
        let reachabilityInteractor = ReachabilityInteractor()
        let presenter = ConversationsPresenter(
            view: moduleViewController,
            isSupport: isSupport,
            updateRepository: appSettings.updateRepository,
            contactDBService: appSettings.contactDBService,
            wireframe: self,
            conversationRepository: appSettings.conversationRespository,
            contactByUserIdInteractor: contactByUserIdInteractor,
            deleteConversationInteractor: deleteConversationInteractor,
            contactToConversationInteractor: contactToConversationInteractor,
            resendMessagesInteractor: resendMessagesInteractor,
            reachabilityInteractor: reachabilityInteractor
        )

        moduleViewController.presenter = presenter
    }
}

// MARK: - Extensions -

extension ConversationsWireframe: ConversationsWireframeInterface {
    func navigateToContacts(contactsCallback: @escaping ContactsCallback, openConverationCallback: @escaping UserIDCallback) {
        if let contactsViewController = self.delegate?.contactsViewController(contactsCallback: contactsCallback,
                                                                              openConverationCallback: openConverationCallback) {
            self.navigationController?.present(contactsViewController, animated: true)
        } else {
            self.navigationController?.presentWireframeWithNavigation(ContactsBookWireframe(contactsCallback: contactsCallback, openConversationCallback: openConverationCallback))
        }
    }
    
    func navigateToConversation(with data: Conversation, isPersonalManager: Bool) {
        self.navigationController?.pushWireframe(ConversationWireframe(with: data, isPersonalManager: isPersonalManager))
    }
}
