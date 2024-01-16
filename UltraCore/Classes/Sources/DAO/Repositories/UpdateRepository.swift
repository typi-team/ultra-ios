//
//  UpdateRepository.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import Foundation
import RxSwift
import GRPC

protocol UpdateRepository: AnyObject {
    
    func setupSubscription()
    func startPingPong()
    func stopPingPong()
    func readAll(in conversation: Conversation)
    var typingUsers: BehaviorSubject<[String: UserTypingWithDate]> { get set }
}

class UpdateRepositoryImpl {
    
    var typingUsers: BehaviorSubject<[String: UserTypingWithDate]> = .init(value: [:])
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let appStore: AppSettingsStore
    fileprivate let contactService: ContactDBService
    fileprivate let messageService: MessageDBService
    fileprivate let updateClient: UpdatesServiceClientProtocol
    fileprivate let conversationService: ConversationDBService
    fileprivate let pingPongInteractorImpl: GRPCErrorUseCase<Void, Void>
    fileprivate let contactByIDInteractor: GRPCErrorUseCase<String, ContactDisplayable>
    fileprivate let deliveredMessageInteractor: GRPCErrorUseCase<Message, MessagesDeliveredResponse>
    
    fileprivate var pintPongTimer: Timer?
    fileprivate var updateListenStream: ServerStreamingCall<ListenRequest, Updates>?
    
    
    init(appStore: AppSettingsStore,
         messageService: MessageDBService,
         contactService: ContactDBService,
         updateClient: UpdatesServiceClientProtocol,
         conversationService: ConversationDBService,
         pingPongInteractorImpl: GRPCErrorUseCase<Void, Void>,
         userByIDInteractor: GRPCErrorUseCase<String, ContactDisplayable>,
         deliveredMessageInteractor: GRPCErrorUseCase<Message, MessagesDeliveredResponse>) {
        self.updateClient = updateClient
        self.appStore = appStore
        self.messageService = messageService
        self.contactService = contactService
        self.conversationService = conversationService
        self.contactByIDInteractor = userByIDInteractor
        self.pingPongInteractorImpl = pingPongInteractorImpl
        self.deliveredMessageInteractor = deliveredMessageInteractor
    }
}

extension UpdateRepositoryImpl: UpdateRepository {
    
    func readAll(in conversation: Conversation) {
        self.conversationService.realAllMessage(for: conversation.idintification)
    }
    
    func stopPingPong() {
        PP.info("❌ stopPintPong")
        self.pintPongTimer?.invalidate()
    }
    
    func startPingPong() {
        PP.info("🐢 startPintPong")
        self.pintPongTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] timer in
            guard let `self` = self else { return timer.invalidate() }
            self.pingPongInteractorImpl
                .executeSingle(params: ())
                .subscribe(onSuccess: {
                    PP.info("Ping pong is called success")
                }, onFailure: {error in
                    PP.error("Ping pong is called with error \(error.localeError)")
                })
                .disposed(by: disposeBag)
        }
    }
    
    func setupSubscription() {
        if appStore.lastState == 0 {
            self.updateClient
                .getInitialState(InitialStateRequest(), callOptions: .default())
                .response
                .whenComplete { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case let .failure(error):
                        PP.warning(error.localizedDescription)
                    case let .success(response):
                        
                        response.contacts.forEach { contact in
                            self.update(contact: ContactDisplayableImpl(contact: contact))
                        }

                        // TODO: - Temporary fix, refactor in reactive way later
                        // We need to make conversations are created first and then
                        // the unread counter is updated.

                        let group = DispatchGroup()
                        response.messages.forEach { message in
                            group.enter()
                            self.update(message: message, completion: {
                                group.leave()
                            })
                        }
                        
                        group.notify(queue: DispatchQueue.main) {
                            self.handleUnread(from: response.chats)
                        }
                        self.appStore.store(last: Int64(response.state))
                        self.setupChangesSubscription(with: response.state)
                    }
                }
        } else {
            self.setupChangesSubscription(with: UInt64(appStore.lastState))
        }
    }
}

private extension UpdateRepositoryImpl {
    func handleUnread(from chats: [Chat]) {
        for chat in chats {
            self.conversationService.incrementUnread(for: chat.chatID, count: Int(chat.unread))
        }
    }
    
    func setupChangesSubscription(with state: UInt64) {
        let state: ListenRequest = .with { $0.localState = .with { $0.state = state } }
        self.updateListenStream?.cancel(promise: nil)
        self.updateListenStream = updateClient.listen(state, callOptions: .default(include: false)) { [weak self] response in
            guard let `self` = self else { return }
            self.appStore.store(last: max(Int64(response.lastState), self.appStore.lastState))
            response.updates.forEach { update in
                if let ofUpdate = update.ofUpdate {
                    self.handle(of: ofUpdate)
                } else if let presence = update.ofPresence {
                    self.handle(of: presence)
                }
            }
        }
        updateListenStream?.status.whenComplete { status in
            print(status)
        }
        
    }
    
    func handle(of presence: Update.OneOf_OfPresence) {
        switch presence {
        case let .typing(typing):
            self.handle(user: typing)
        case let .audioRecording(pres):
            PP.debug(pres.textFormatString())
        case let .userStatus(status):
            _ = self.contactService.update(contact: status).subscribe()
        case let .mediaUploading(pres):
            PP.debug(pres.textFormatString())
        case let .callReject(reject):
            self.dissmissCall(in: reject.room)
        case let .callRequest(callRequest):
            self.handleIncoming(callRequest: callRequest)
        case let .callCancel(callrequest):
            self.dissmissCall(in: callrequest.room)
        case let .block(blockMessage):
            self.contactService
                .block(user: blockMessage.user, blocked: true)
                .subscribe()
                .disposed(by: disposeBag)
        case let .unblock(blockMessage):
            self.contactService
                .block(user: blockMessage.user, blocked: false)
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    func dissmissCall(in room: String) {
        DispatchQueue.main.async {
            if var topController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if topController is IncomingCallViewController {
                    topController.dismiss(animated: true)
                }
            }
        }
    }
    
    func handleIncoming(callRequest: CallRequest) {
        self.contactByIDInteractor
            .executeSingle(params: callRequest.sender)
            .flatMap({ self.contactService.save(contact: $0) })
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { () in
                if var topController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.presentWireframe(IncomingCallWireframe(call:.incoming(callRequest)))
                }
            })
            .disposed(by: disposeBag)
    }
    
    func handle(of update: Update.OneOf_OfUpdate) {
        switch update {
        case let .message(message):
            self.update(message: message, completion: { })
            self.handleNewMessageOnRead(message: message)
        case let .contact(contact):
            self.update(contact: ContactDisplayableImpl(contact: contact))
        case let .messagesDelivered(message):
            self.messagesDelivered(message: message)
        case let .messagesRead(message):
            self.messagesReaded(message: message)
        case let .messagesDeleted(message):
            self.delete(message)
        case let .chatDeleted(chat):
            self.deleteConversation(chat)
        case let .moneyTransferStatus(status):
            PP.debug(status.textFormatString())
        case .stockTransferStatus(let data):
            PP.debug(data.textFormatString())
        case .coinTransferStatus(let data):
            PP.debug(data.textFormatString())
        }
    }
}

extension UpdateRepositoryImpl {
    
    func handleNewMessageOnRead(message: Message) {
        guard message.sender.userID != self.appStore.userID() else { return }
        self.conversationService.incrementUnread(for: message.receiver.chatID)
    }
    
    func update(message: Message, completion: @escaping (() -> Void)) {
        let contactID = message.peerId(user: self.appStore.userID())
        let contact = self.contactService.contact(id: contactID)
        print("[Chat ID]: \(message.receiver.chatID)")
        if contact == nil {
            _ = self.contactByIDInteractor
                .executeSingle(params: contactID)
                .flatMap({ self.contactService.save(contact: $0) })
                .flatMap({ _ in self.conversationService.createIfNotExist(from: message) })
                .flatMap({ self.messageService.update(message: message) })
                .subscribe(onDisposed: {
                    completion()
                })

        } else {
            self.conversationService
                .createIfNotExist(from: message)
                .flatMap({ self.messageService.update(message: message) })
                .subscribe()
                .dispose()
        }
        
        if message.state.delivered == false && message.isIncome {
            self.deliveredMessageInteractor
                .executeSingle(params: message)
                .subscribe()
                .dispose()
        }
    }
    
    func update(contact interface: ContactDisplayable) {
        _ = self.contactService.save(contact: interface)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
    }
}

extension UpdateRepositoryImpl {
    func delete(_ message: MessagesDeleted) {
        self.messageService.deleteMessages(in: message.chatID, ranges: message.convertToClosedRanges())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func deleteConversation(_ data: ChatDeleted) {
        self.conversationService.delete(conversation: data.chatID)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func handle(user typing: UserTyping) {
        guard var users = try? typingUsers.value() else {
            return
        }
        
        users[typing.chatID] = .init(user: typing)
        self.typingUsers.on(.next(users))
        self.handleRemove(user: typing)
        
    }
    
    func handleRemove(user typing: UserTyping) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {[weak self]  in
            guard let `self` = self else { return }
            guard let users = try? self.typingUsers.value(),
                  let createdAt = users[typing.chatID]?.createdAt,
                  Date().timeIntervalSince(createdAt) > kTypingMinInterval else {
                return
            }
            self.typingUsers.on(.next(users))
        }
    }
    
    func messagesDelivered(message delivered: MessagesDelivered) {
        self.messageService
            .delivered(message: delivered)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
    func messagesReaded(message delivered: MessagesRead) {
        self.messageService
            .readed(message: delivered)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
            .disposed(by: disposeBag)
        
    }
}

extension MessagesDeleted {
    
    func convertToClosedRanges() -> [ClosedRange<Int64>] {
        var closedRanges: [ClosedRange<Int64>] = []

        for messagesRange in self.range {
            if messagesRange.minSeqNumber > messagesRange.maxSeqNumber {
                continue
            }

            let closedRange = ClosedRange(uncheckedBounds: (Int64(messagesRange.minSeqNumber), Int64(messagesRange.maxSeqNumber)))
            closedRanges.append(closedRange)
        }

        return closedRanges
    }
}
