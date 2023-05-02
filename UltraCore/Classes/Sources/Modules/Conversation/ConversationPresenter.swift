//
//  ConversationPresenter.swift
//  Pods
//
//  Created by Slam on 4/25/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import RxSwift
import RealmSwift

final class ConversationPresenter {

    // MARK: - Private properties -
    
    final let conversation: Conversation

    fileprivate let disposeBag = DisposeBag()
    private unowned let view: ConversationViewInterface
    fileprivate let messageRepository: MessageRepository
    private let wireframe: ConversationWireframeInterface
    fileprivate let conversationRepository: ConversationRepository
    private let messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>

    // MARK: - Public properties -

    lazy var messages: Observable<Results<DBMessage>> = messageRepository.messages(chatID: conversation.idintification)

    // MARK: - Lifecycle -

    init(conversation: Conversation,
         view: ConversationViewInterface,
         messageRepository: MessageRepository,
         wireframe: ConversationWireframeInterface,
         conversationRepository: ConversationRepository,
         messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>) {
        self.view = view
        self.wireframe = wireframe
        self.conversation = conversation
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        self.messageSenderInteractor = messageSenderInteractor
    }
}

// MARK: - Extensions -

extension ConversationPresenter: ConversationPresenterInterface {
    
    func send(message text: String) {
        var params = MessageSendRequest()
        params.message.text.content = text
        params.peer.user = .with({ [weak self] peer in
            guard let `self` = self else { return }
            peer.userID = self.conversation.idintification
        })
        params.message.meta.created = Date().nanosec
        
        var message = Message()
        message.id = UUID().uuidString
        message.text = TextMessage.with({ $0.content = text })
        message.receiver = .with({
            $0.chatID = conversation.idintification
            $0.userID = conversation.peer?.userID ?? ""
        })
        
        self.conversationRepository
            .createIfNotExist(from: message)
            .subscribe().disposed(by: disposeBag)
            
        self.messageRepository.save(message: message)
            .andThen(self.messageSenderInteractor.executeSingle(params: params))
            .flatMap({ [weak self] (response: MessageSendResponse) in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                message.meta.created = response.meta.created
                message.state.delivered = false
                message.state.read = false

                return self.messageRepository.update(message: message)
            })

            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
}
