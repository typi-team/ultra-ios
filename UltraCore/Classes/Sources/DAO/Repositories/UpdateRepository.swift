//
//  UpdateRepository.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import Foundation
import RxSwift
import GRPC
import CallKit

protocol UpdateRepository: AnyObject {
    
    func setupSubscription()
    func startPingPong()
    func stopSession()
    func retreiveContactStatuses()
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
    fileprivate let retrieveContactStatusesInteractorImpl: GRPCErrorUseCase<Void, Void>
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
         retrieveContactStatusesInteractorImpl: GRPCErrorUseCase<Void, Void>,
         deliveredMessageInteractor: GRPCErrorUseCase<Message, MessagesDeliveredResponse>) {
        self.updateClient = updateClient
        self.appStore = appStore
        self.messageService = messageService
        self.contactService = contactService
        self.conversationService = conversationService
        self.contactByIDInteractor = userByIDInteractor
        self.pingPongInteractorImpl = pingPongInteractorImpl
        self.deliveredMessageInteractor = deliveredMessageInteractor
        self.retrieveContactStatusesInteractorImpl = retrieveContactStatusesInteractorImpl
    }
}

extension UpdateRepositoryImpl: UpdateRepository {
    
    func readAll(in conversation: Conversation) {
        self.conversationService.readAllMessage(for: conversation.idintification)
    }
    
    func stopSession() {
        PP.info("❌ stopPintPong")
        self.pintPongTimer?.invalidate()
        self.updateListenStream?.cancel(promise: nil)
        self.contactService.updateContact(status: .unknown)
    }
    
    func retreiveContactStatuses() {
        PP.info("📇 retreiveContactStatuses")
        self.retrieveContactStatusesInteractorImpl.executeSingle(params: ())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func startPingPong() {
        DispatchQueue.main.async {
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
                        // We need to make sure that conversations are created first and then
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
                        self.retreiveContactStatuses()
                    }
                }
        } else {
            self.retreiveContactStatuses()
            self.setupChangesSubscription(with: UInt64(appStore.lastState))
        }
    }
    
}

private extension UpdateRepositoryImpl {
    func handleUnread(from chats: [Chat]) {
        for chat in chats {
            conversationService.setUnread(for: chat.chatID, count: Int(chat.unread))
        }
        UnreadMessagesService.updateUnreadMessagesCount()
    }
    
    func setupChangesSubscription(with state: UInt64) {
        let state: ListenRequest = .with { $0.localState = .with { $0.state = state } }
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
        PP.debug("[PRESENCE] - \(presence)")
        switch presence {
        case let .typing(typing):
            self.handle(user: typing)
        case let .audioRecording(pres):
            PP.debug(pres.textFormatString())
        case let .userStatus(status):
            if contactService.contact(id: status.userID) != nil {
                contactService.update(contact: status)
                    .subscribe()
                    .disposed(by: disposeBag)
            } else {
                contactByIDInteractor.executeSingle(params: status.userID)
                    .flatMap { [weak self] contact in
                        guard let self = self else {
                            throw NSError.selfIsNill
                        }
                        return self.contactService.save(contact: contact)
                    }
                    .flatMap { [weak self] _ in
                        guard let self = self else {
                            throw NSError.selfIsNill
                        }
                        return self.contactService.update(contact: status)
                    }
                    .subscribe()
                    .disposed(by: disposeBag)
            }
        case let .mediaUploading(pres):
            PP.debug(pres.textFormatString())
        case let .callReject(reject):
            PP.debug("[CALL] - Server Call reject - \(reject.room)")
            self.dissmissCall(in: reject.room)
        case let .callCancel(callrequest):
            PP.debug("[CALL] - Server Call cancel - \(callrequest.room)")
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
        case .callRequest:
            break
        }
    }
    
    func dissmissCall(in room: String) {
        DispatchQueue.main.async {
            UltraVoIPManager.shared.serverEndCall()
        }
    }
        
    func handle(of update: Update.OneOf_OfUpdate) {
        PP.debug("[UPDATE] - \(update)")
        switch update {
        case let .message(message):
            let senderID = appStore.userID()
            self.update(message: message, completion: {
                guard message.sender.userID != senderID else { return }
                UnreadMessagesService.updateUnreadMessagesCount()
            })
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
        case .chat:
            break
        }
    }
}

extension UpdateRepositoryImpl {
    
    func handleNewMessageOnRead(message: Message) {
        PP.debug("Handle new message on read")
        guard message.sender.userID != self.appStore.userID() else { return }
        self.conversationService.incrementUnread(for: message.receiver.chatID)
    }
    
    func update(message: Message, completion: @escaping (() -> Void)) {
        let contactID = message.peerId(user: self.appStore.userID())
        let contact = self.contactService.contact(id: contactID)
        if contact == nil {
            self.contactByIDInteractor
                .executeSingle(params: contactID)
                .flatMap({ self.contactService.save(contact: $0) })
                .flatMap({ _ in self.conversationService.createIfNotExist(from: message) })
                .flatMap({ self.messageService.update(message: message) })
                .subscribe(onDisposed: {
                    completion()
                })
                .disposed(by: disposeBag)

        } else {
            self.conversationService
                .createIfNotExist(from: message)
                .flatMap({ self.messageService.update(message: message) })
                .subscribe(onDisposed: {
                    completion()
                })
                .disposed(by: disposeBag)
        }
        
        if message.state.delivered == false && message.isIncome {
            self.deliveredMessageInteractor
                .executeSingle(params: message)
                .subscribe()
                .disposed(by: disposeBag)
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

extension UIApplication {
    class func topViewController(root: UIViewController? = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController) -> UIViewController? {
        if let nav = root as? UINavigationController {
            return topViewController(root: nav.visibleViewController)

        } else if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(root: selected)

        } else if let presented = root?.presentedViewController {
            return topViewController(root: presented)
        }
        return root
    }
}
