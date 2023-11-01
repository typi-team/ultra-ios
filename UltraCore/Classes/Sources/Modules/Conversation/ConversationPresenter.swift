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
    fileprivate let appStore: AppSettingsStore
    
    fileprivate let callService: CallServiceClientProtocol
    
    fileprivate let mediaRepository: MediaRepository
    fileprivate let updateRepository: UpdateRepository
    private unowned let view: ConversationViewInterface
    fileprivate let messageRepository: MessageRepository
    fileprivate let contactRepository: ContactsRepository
    private let wireframe: ConversationWireframeInterface
    fileprivate let conversationRepository: ConversationRepository
    

    private let deleteMessageInteractor: UseCase<([Message], Bool), Void>
    private let sendTypingInteractor: UseCase<String, SendTypingResponse>
    private let readMessageInteractor: UseCase<Message, MessagesReadResponse>
    private let messagesInteractor: UseCase<GetChatMessagesRequest, [Message]>
    fileprivate let sendMoneyInteractor: UseCase<TransferPayload, TransferResponse>
    private let messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>


    // MARK: - Public properties -

    lazy var messages: Observable<[Message]> = messageRepository.messages(chatID: conversation.idintification)
        .map({ $0.sorted(by: { m1, m2 in m1.meta.created < m2.meta.created }) })
        .do(onNext: { [weak self] messages in
            guard let `self` = self else { return }
            let messages = messages.filter({ $0.fileID != nil })
                .filter({ self.mediaRepository.mediaURL(from: $0) == nil })
            guard !messages.isEmpty else { return }

            Observable.from(messages)
                .flatMap { [weak self] message in
                    guard let `self` = self else { throw NSError.selfIsNill }
                    return self.mediaRepository.download(from: message)
                }
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .observe(on: MainScheduler.instance)
                .subscribe()
                .disposed(by: self.disposeBag)
        })

    // MARK: - Lifecycle -

    init(userID: String,
         appStore: AppSettingsStore,
         conversation: Conversation,
         view: ConversationViewInterface,
         mediaRepository: MediaRepository,
         callService: CallServiceClientProtocol,
         updateRepository: UpdateRepository,
         messageRepository: MessageRepository,
         contactRepository: ContactsRepository,
         wireframe: ConversationWireframeInterface,
         conversationRepository: ConversationRepository,
         deleteMessageInteractor: UseCase<([Message], Bool), Void>,
         messagesInteractor: UseCase<GetChatMessagesRequest, [Message]>,
         sendTypingInteractor: UseCase<String, SendTypingResponse>,
         readMessageInteractor: UseCase<Message, MessagesReadResponse>,
         sendMoneyInteractor: UseCase<TransferPayload, TransferResponse>,
         messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>) {
        self.view = view
        self.userID = userID
        self.appStore = appStore
        self.wireframe = wireframe
        self.callService = callService
        self.conversation = conversation
        self.mediaRepository = mediaRepository
        self.updateRepository = updateRepository
        self.contactRepository = contactRepository
        self.messageRepository = messageRepository
        self.messagesInteractor = messagesInteractor
        self.sendMoneyInteractor = sendMoneyInteractor
        self.sendTypingInteractor = sendTypingInteractor
        self.readMessageInteractor = readMessageInteractor
        self.conversationRepository = conversationRepository
        self.deleteMessageInteractor = deleteMessageInteractor
        self.messageSenderInteractor = messageSenderInteractor
    }
}

// MARK: - Extensions -

extension ConversationPresenter: ConversationPresenterInterface {
    func isBlock() -> Bool {
        return self.conversation.peer?.isBlocked ?? false
    }
    
    func block() {
        guard let contact = self.conversation.peer else { return }
        let userId = contact.userID
        if contact.isBlocked {
            AppSettingsImpl.shared.conversationService.unblockUser(.with({
                $0.userID = userId
                $0.chatID = self.conversation.idintification
            }), callOptions: .default()).response.whenComplete({[weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.update(block: false, user: userId)
                    case .failure(let error):
                        self.view.show(error: error.localizedDescription)
                    }
                }
            })
        } else {
            AppSettingsImpl.shared.conversationService.blockUser(.with({
                $0.chatID = self.conversation.idintification
                $0.userID = userId
            }), callOptions: .default()).response.whenComplete({[weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.update(block: true, user: userId)
                    case .failure(let error):
                        self.view.show(error: error.localizedDescription)
                    }
                }
            })
        }
    }
    
    private func update(block: Bool, user id: String) {
        self.contactRepository.block(user: id, blocked: block)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    func report(_ messages: [Message]) {
        guard !messages.isEmpty else { return }
        
        AppSettingsImpl.shared.messageService.complain(.with({
            $0.chatID = self.conversation.idintification
            $0.messageID = messages.first!.id
        }), callOptions: .default()).response
            .whenComplete({[weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.view.reported()
                    case let .failure(error):
                        self.view.show(error: error.localizedDescription)
                    }
                }
            })
    }
    func callVideo() {
        self.createCall(with: true)
    }
    
    func callVoice() {
        self.createCall()
    }
    
    func createCall(with video: Bool = false) {
        guard let user = self.conversation.peer?.userID else { return }
        self.callService.create(.with({
            $0.users = [user]
            $0.video = video
        }), callOptions: .default())
            .response
            .whenComplete({ [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case let .success(response):
                    DispatchQueue.main.async {
                        self.wireframe.navigateToCall(response: response, isVideo: video)
                    }
                case let .failure(error):
                    PP.error(error.localizedDescription)
                }
            })
    }
    
    func send(location: LocationMessage) {
        var params = MessageSendRequest()
        
        params.peer.user = .with({ [weak self] peer in
            guard let `self` = self else { return }
            peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
        })

        var message = Message()
        message.id = UUID().uuidString
        message.meta.created = Date().nanosec
        message.receiver = .with({[weak self] receiver in
            guard let `self` = self else { return }
            receiver.chatID = conversation.idintification
            receiver.userID = self.conversation.peer?.userID ?? ""
        })
        message.location = location
        
        message.sender = .with({ $0.userID = self.userID })
        message.meta = .with({
            $0.created = Date().nanosec
        })
        
        params.message = message
        
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
    
    func send(contact: ContactMessage) {
        var params = MessageSendRequest()
        
        params.peer.user = .with({ [weak self] peer in
            guard let `self` = self else { return }
            peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
        })

        var message = Message()
        message.id = UUID().uuidString
        message.meta.created = Date().nanosec
        message.receiver = .with({[weak self] receiver in
            guard let `self` = self else { return }
            receiver.chatID = conversation.idintification
            receiver.userID = self.conversation.peer?.userID ?? ""
        })
        message.contact = contact
        
        message.sender = .with({ $0.userID = self.userID })
        message.meta = .with({
            $0.created = Date().nanosec
        })
        
        params.message = message
        
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
    func delete(_ messages: [Message], all: Bool) {
        self.deleteMessageInteractor.executeSingle(params: (messages, all))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func openMoneyController() {
        self.wireframe.openMoneyController(callback: { [weak self] value in
            guard let `self` = self,
                  let receiverID = self.conversation.peer?.userID else { return }
            var params = MessageSendRequest()

            params.peer.user = .with({ peer in
                peer.userID = receiverID
            })

            params.message.id = UUID().uuidString
            params.message.meta.created = Date().nanosec

            var message = Message()
            message.money = .with({
                $0.transactionID = value.transactionID
                $0.money = .with({ money in
                    money.units = value.amout
                    money.currencyCode = value.currency
                })
            })
            message .text = params.textFormatString()
            message.id = params.message.id
            message.receiver = .with({ receiver in
                receiver.userID = receiverID
                receiver.chatID = self.conversation.idintification
            })
            message.sender = .with({ $0.userID = self.userID })
            message.meta = .with({ $0.created = Date().nanosec })
            
            params.message = message
            
            self.conversationRepository
                .createIfNotExist(from: message)
                .flatMap { self.messageRepository.save(message: message) }
                .flatMap { self.messageSenderInteractor.executeSingle(params: params) }
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
        })
    }
    
    func loadMoreMessages(maxSeqNumber: UInt64 ) {
        self.messagesInteractor
            .executeSingle(params: .with({
                $0.chatID = self.conversation.idintification
                $0.maxSeqNumber = UInt64(maxSeqNumber)
            }))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: {[weak self] message in
                guard let `self` = self else { return }
                self.view.stopRefresh(removeController: message.isEmpty)
            })
            .disposed(by: disposeBag)
    }
    func navigateToContact() {
        guard let contact = self.conversation.peer else { return }
        self.wireframe.navigateTo(contact: contact)
    }
    
    func mediaURL(from message: Message) -> URL? {
        return self.mediaRepository.mediaURL(from: message)
    }
    
    func upload(file: FileUpload) {
        self.mediaRepository
            .upload(file: file, in: conversation)
            .flatMap({ [weak self] request in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageSenderInteractor.executeSingle(params: request)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { _ in PP.debug(file.mime) },
                       onFailure: { error in PP.debug(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
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
                    self.view.blocked(is: contact.isBlocked)
                    self.view.setup(conversation: self.conversation)
                })
                .disposed(by: disposeBag)
        }
        
        self.messageRepository.messages(chatID: conversation.idintification)
            .debounce(RxTimeInterval.milliseconds(400), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] messages in
                guard let `self` = self else { return }
                let unreadMessages = messages.filter({ $0.sender.userID != self.appStore.userID() }).filter({ $0.state.read == false })
                guard let lastUnreadMessage = unreadMessages.last else { return }
                self.updateRepository.readAll(in: self.conversation)
                self.readMessageInteractor.executeSingle(params: lastUnreadMessage)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func send(message text: String) {
        var params = MessageSendRequest()
        
        params.peer.user = .with({ [weak self] peer in
            guard let `self` = self else { return }
            peer.userID = self.conversation.peer?.userID ?? "u1FNOmSc0DAwM"
        })
        params.message.text = text
        params.message.id = UUID().uuidString
        params.message.meta.created = Date().nanosec
        
        var message = Message()
        message.text = text
        message.id = params.message.id
        message.receiver = .with({[weak self] receiver in
            guard let `self` = self else { return }
            receiver.chatID = self.conversation.idintification
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

extension Message {
    var isIncome: Bool { self.receiver.userID == AppSettingsImpl.shared.appStore.userID() }
}
