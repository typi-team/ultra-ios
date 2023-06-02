//
//  ConversationWireframe.swift
//  Pods
//
//  Created by Slam on 4/25/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class ConversationWireframe: BaseWireframe<ConversationViewController> {

    // MARK: - Private properties -

    // MARK: - Module setup -

    init(with conversation: Conversation) {
        let moduleViewController = ConversationViewController()
        super.init(viewController: moduleViewController)
        let messageSenderInteractor = SendMessageInteractor.init(messageService: appSettings.messageService)
        let sendTypingInteractor = SendTypingInteractor.init(messageService: appSettings.messageService)
        let readMessageInteractor = ReadMessageInteractor.init(messageService: appSettings.messageService)
        let presenter = ConversationPresenter(userID: appSettings.appStore.userID(),
                                              appStore: appSettings.appStore,
                                              conversation: conversation,
                                              view: moduleViewController,
                                              updateRepository: appSettings.updateRepository,
                                              messageRepository: appSettings.messageRespository,
                                              contactRepository: appSettings.contactRepository,
                                              wireframe: self,
                                              conversationRepository: appSettings.conversationRespository,
                                              sendTypingInteractor: sendTypingInteractor,
                                              readMessageInteractor: readMessageInteractor,
                                              messageSenderInteractor: messageSenderInteractor)
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension ConversationWireframe: ConversationWireframeInterface {
}
