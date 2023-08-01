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

    // MARK: - Module setup -

    init() {
        let moduleViewController = ConversationsViewController()
        super.init(viewController: moduleViewController)

        let deleteConversationInteractor = DeleteConversationInteractor(conversationDBService: appSettings.conversationDBService,
                                                                        conversationService: appSettings.conversationService)
        let presenter = ConversationsPresenter(view: moduleViewController,
                                               updateRepository: appSettings.updateRepository,
                                               messageRepository: appSettings.messageRespository,
                                               wireframe: self,
                                               conversationRepository: appSettings.conversationRespository,
                                               retrieveContactStatusesInteractor: RetrieveContactStatusesInteractor.init(appStore: appSettings.appStore,
                                                                                                                         contactDBService: appSettings.contactDBService,
                                                                                                                         contactService: appSettings.contactsService),
                                               deleteConversationInteractor: deleteConversationInteractor,
                                               userStatusUpdateInteractor: UpdateOnlineInteractor(userService: appSettings.userService))
        moduleViewController.presenter = presenter
    }
}

// MARK: - Extensions -

extension ConversationsWireframe: ConversationsWireframeInterface {
    
    func navigateToContacts() {
        self.navigationController?.presentWireframeWithNavigation(ContactsBookWireframe())
    }
    
    func navigateToConversation(with data: Conversation) {
        self.navigationController?.pushWireframe(ConversationWireframe(with: data))
    }
}
