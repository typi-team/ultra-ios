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
    
    var conversation: Conversation
    
    fileprivate let userID: String
    fileprivate let disposeBag = DisposeBag()
    fileprivate let updateRepository: UpdateRepository
    private unowned let view: ConversationViewInterface
    fileprivate let messageRepository: MessageRepository
    fileprivate let contactRepository: ContactsRepository
    private let wireframe: ConversationWireframeInterface
    fileprivate let conversationRepository: ConversationRepository
    private let sendTypingInteractor: UseCase<String, SendTypingResponse>
    private let messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>
    

    // MARK: - Public properties -

    lazy var messages: Observable<Results<DBMessage>> = messageRepository.messages(chatID: conversation.idintification)

    // MARK: - Lifecycle -

    init(userID: String,
         conversation: Conversation,
         view: ConversationViewInterface,
         updateRepository: UpdateRepository,
         messageRepository: MessageRepository,
         contactRepository: ContactsRepository,
         wireframe: ConversationWireframeInterface,
         conversationRepository: ConversationRepository,
         sendTypingInteractor: UseCase<String, SendTypingResponse>,
         messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>) {
        self.view = view
        self.userID = userID
        self.wireframe = wireframe
        self.conversation = conversation
        self.updateRepository = updateRepository
        self.contactRepository = contactRepository
        self.messageRepository = messageRepository
        self.sendTypingInteractor = sendTypingInteractor
        self.conversationRepository = conversationRepository
        self.messageSenderInteractor = messageSenderInteractor
    }
}

// MARK: - Extensions -

extension ConversationPresenter: ConversationPresenterInterface {
    func typing(is active: Bool) {
        self.sendTypingInteractor
            .executeSingle(params: conversation.idintification)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    func viewDidLoad() {
        self.view.setup(conversation: conversation)
        self.updateRepository.typingUsers
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .map { [weak self] users -> UserTypingWithDate? in
                guard let `self` = self else { return nil }
                return users[self.conversation.idintification]
            }
            .compactMap { $0 }
            .subscribe (onNext: { [weak self] typingUser in
                guard let `self` = self else { return }
                self.view.display(is: typingUser)
            })
            .disposed(by: disposeBag)
        
        if let userID = self.conversation.peer?.userID {
            self.contactRepository
                .contacts()
                .map { $0.filter({ contact in contact.userID == userID }) }
                .compactMap({ $0.first })
                .subscribe(onNext: { [weak self] contact in
                    guard let `self` = self else { return }
                    self.conversation.peer = contact
                    self.view.setup(conversation: self.conversation)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func send(message text: String) {
        var params = MessageSendRequest()
        
        params.peer.user = .with({ [weak self] peer in
            guard let `self` = self else { return }
            peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
        })
        params.message.text = text
        params.message.id = UUID().uuidString
        params.message.meta.created = Date().nanosec
        
        var message = Message()
        message.text = text
        message.id = params.message.id
        message.receiver = .with({[weak self] receiver in
            guard let `self` = self else { return }
            receiver.chatID = conversation.idintification
            receiver.userID = self.conversation.peer?.userID ?? ""
        })
        message.sender = .with({ $0.userID = self.userID })
        message.meta = .with({
            $0.created = Date().nanosec
        })
        
        self.conversationRepository
            .createIfNotExist(from: message)
            .flatMap{ self.messageRepository.save(message: message)}
            .flatMap{self.messageSenderInteractor.executeSingle(params: params)}
            .flatMap({ [weak self] (response: MessageSendResponse) in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                message.meta.created = response.meta.created
                message.state.delivered = false
                message.state.read = false
                message.seqNumber = response.seqNumber

                return self.messageRepository.update(message: message)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
}
