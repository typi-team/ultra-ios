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

    fileprivate weak var delegate: UltraCoreSettingsDelegate?
    fileprivate weak var futureDelegate: UltraCoreFutureDelegate?
    
    fileprivate let conversation: Conversation
    
    init(with conversation: Conversation,
         delegate: UltraCoreSettingsDelegate? = UltraCoreSettings.delegate,
         futureDelegate: UltraCoreFutureDelegate? = UltraCoreSettings.futureDelegate) {
        self.delegate = delegate
        self.conversation = conversation
        self.futureDelegate = futureDelegate
        let moduleViewController = ConversationViewController()
        super.init(viewController: moduleViewController)
        
        let sendTypingInteractor = SendTypingInteractor.init(messageService: appSettings.messageService)
        let readMessageInteractor = ReadMessageInteractor.init(messageService: appSettings.messageService)
        let messageSenderInteractor = SendMessageInteractor.init(messageService: appSettings.messageService)
        let archiveMessages = MessagesInteractor(messageDBService: appSettings.messageDBService, messageService: appSettings.messageService)
        let deleteInteractor = DeleteMessageInteractor.init(messageDBService: appSettings.messageDBService,
                                                            messageService: appSettings.messageService)
        let makeVibrationInteractor = MakeVibrationInteractor()
        let messageSentSoundInteractor = MakeSoundInteractor()
        
        let blockContactInteractor = BlockContactInteractor(userService: appSettings.userService, contactDBService: appSettings.contactDBService)
        let acceptContactInteractor = AcceptContactInteractor(contactService: appSettings.contactsService)
        let presenter = ConversationPresenter(
            userID: appSettings.appStore.userID(),
            appStore: appSettings.appStore,
            conversation: conversation,
            view: moduleViewController,
            mediaRepository: appSettings.mediaRepository, callService: appSettings.callService,
            updateRepository: appSettings.updateRepository,
            messageRepository: appSettings.messageRespository,
            contactRepository: appSettings.contactRepository,
            wireframe: self,
            conversationRepository: appSettings.conversationRespository,
            deleteMessageInteractor: deleteInteractor,
            blockContactInteractor: blockContactInteractor,
            messagesInteractor: archiveMessages,
            sendTypingInteractor: sendTypingInteractor,
            readMessageInteractor: readMessageInteractor,
            sendMoneyInteractor: SendMoneyInteractor(),
            makeVibrationInteractor: makeVibrationInteractor,
            messageSenderInteractor: messageSenderInteractor,
            messageSentSoundInteractor: messageSentSoundInteractor,
            acceptContactInteractor: acceptContactInteractor
        )
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension ConversationWireframe: ConversationWireframeInterface {
    func navigateToCall(response: CreateCallResponse, isVideo: Bool) {
        guard let reciever = self.conversation.peer?.userID else { return }
        let info = CallOutging(video: isVideo, host: response.host, room: response.room, sender: reciever, accessToken: response.accessToken)
        self.navigationController?.presentWireframe(IncomingCallWireframe(call: .outcoming(info)), animated: true, completion: nil)
    }
    
    func navigateTo(contact: ContactDisplayable) {
        if let delegate = self.delegate {
            if let viewController = delegate.contactViewController(contact: contact.phone) {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            self.navigationController?.pushWireframe(ContactWireframe(contact: contact), animated: true, removeFromStack: nil)
        }
    }
    
    func openMoneyController(callback: @escaping MoneyCallback) {
        if let innerViewController = self.delegate?.moneyViewController(callback: callback) {
            self.viewController.present(innerViewController, animated: true)
        } else {
            let wireframe = MoneyTransferWireframe(conversation: self.conversation, moneyCallback: callback)
            self.viewController.present(wireframe.viewController, animated: true)
        }
    }
    
    func closeChat() {
        navigationController?.popViewController(animated: true)
    }
}
