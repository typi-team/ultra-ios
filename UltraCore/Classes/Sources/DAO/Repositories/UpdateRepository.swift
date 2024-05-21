//
//  UpdateRepository.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import Foundation
import RealmSwift
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
    var updateSyncObservable: Observable<Void> { get }
    var supportOfficesObservable: Observable<SupportOfficesResponse?> { get }
    var isConnectedToListenStream: Bool { get }
}

class UpdateRepositoryImpl {
    
    var typingUsers: BehaviorSubject<[String: UserTypingWithDate]> = .init(value: [:])
    var updateSyncObservable: Observable<Void> {
        updateSyncSubject.asObservable().share(replay: 1)
    }
    var supportOfficesObservable: Observable<SupportOfficesResponse?> {
        supportOfficesSubject.asObservable().startWith(nil).share(replay: 1)
    }
    var isConnectedToListenStream: Bool = false
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let appStore: AppSettingsStore
    fileprivate let contactService: ContactDBService
    fileprivate let messageService: MessageDBService
    fileprivate let updateClient: UpdatesServiceClientProtocol
    fileprivate let conversationService: ConversationDBService
    fileprivate let pingPongInteractorImpl: GRPCErrorUseCase<Void, Void>
    fileprivate let retrieveContactStatusesInteractorImpl: GRPCErrorUseCase<Void, Void>
    fileprivate let updateContactStatusInteractor: GRPCErrorUseCase<String, Void>
    fileprivate let contactByIDInteractor: GRPCErrorUseCase<String, ContactDisplayable>
    fileprivate let deliveredMessageInteractor: GRPCErrorUseCase<Message, MessagesDeliveredResponse>
    fileprivate let chatInteractor: GRPCErrorUseCase<String, Chat>
    fileprivate let initSupportInteractor: GRPCErrorUseCase<InitSupportChatsRequest, InitSupportChatsResponse>
    fileprivate let chatToConversationInteractor: GRPCErrorUseCase<ChatToConversationParams, Void>
    
    fileprivate var pintPongTimer: Timer?
    fileprivate var updateListenStream: ServerStreamingCall<ListenRequest, Updates>?
    
    private let updateSyncSubject = ReplaySubject<Void>.create(bufferSize: 1)
    private let supportOfficesSubject = ReplaySubject<SupportOfficesResponse?>.create(bufferSize: 1)
    private let semaphore = DispatchSemaphore(value: 1)
    
    init(appStore: AppSettingsStore,
         messageService: MessageDBService,
         contactService: ContactDBService,
         updateClient: UpdatesServiceClientProtocol,
         conversationService: ConversationDBService,
         pingPongInteractorImpl: GRPCErrorUseCase<Void, Void>,
         userByIDInteractor: GRPCErrorUseCase<String, ContactDisplayable>,
         retrieveContactStatusesInteractorImpl: GRPCErrorUseCase<Void, Void>,
         updateContactStatusInteractor: GRPCErrorUseCase<String, Void>,
         deliveredMessageInteractor: GRPCErrorUseCase<Message, MessagesDeliveredResponse>,
         chatInteractor: GRPCErrorUseCase<String, Chat>,
         initSupportInteractor: GRPCErrorUseCase<InitSupportChatsRequest, InitSupportChatsResponse>,
         chatToConversationInteractor: GRPCErrorUseCase<ChatToConversationParams, Void>
    ) {
        self.updateClient = updateClient
        self.appStore = appStore
        self.messageService = messageService
        self.contactService = contactService
        self.conversationService = conversationService
        self.contactByIDInteractor = userByIDInteractor
        self.pingPongInteractorImpl = pingPongInteractorImpl
        self.deliveredMessageInteractor = deliveredMessageInteractor
        self.retrieveContactStatusesInteractorImpl = retrieveContactStatusesInteractorImpl
        self.updateContactStatusInteractor = updateContactStatusInteractor
        self.chatInteractor = chatInteractor
        self.initSupportInteractor = initSupportInteractor
        self.chatToConversationInteractor = chatToConversationInteractor
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
        self.isConnectedToListenStream = false
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
        _ = Realm.myRealm()
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
                            if message.shouldBeSaved {
                                group.enter()
                                self.semaphore.wait()
                                self.update(message: message, completion: {
                                    self.semaphore.signal()
                                    group.leave()
                                })
                            }
                        }
                        
                        group.notify(queue: DispatchQueue.main) { [weak self] in
                            guard let self else { return }
                            self.handleUnread(from: response.chats)
                            let chatRequests = response.chats.map {
                                self.chatToConversationInteractor.executeSingle(params: .init(chat: $0, imagePath: nil)).asObservable()
                            }
                            Observable.zip(chatRequests)
                                .subscribe { [weak self] _ in
                                    self?.initializeSupportChats()
                                }
                                .disposed(by: disposeBag)
                            self.updateSyncSubject.onNext(())
                        }
                        self.appStore.store(last: Int64(response.state))
                        self.setupChangesSubscription(with: response.state)
                        self.retreiveContactStatuses()
                    }
                }
        } else {
            updateSyncSubject.onNext(())
            self.retreiveContactStatuses()
            self.initializeSupportChats()
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
        PP.debug("Setting up change subscription with state - \(state)")
        let state: ListenRequest = .with { $0.localState = .with { $0.state = state } }
        self.isConnectedToListenStream = true
        self.updateListenStream = updateClient.listen(state, callOptions: .default(include: false)) { [weak self] response in
            guard let `self` = self else { return }
            response.updates.forEach { update in
                if let ofUpdate = update.ofUpdate {
                    self.handle(of: ofUpdate)
                } else if let presence = update.ofPresence {
                    self.handle(of: presence)
                }
            }
            PP.debug("Trying to save last state; Server last state - \(response.lastState); local last state - \(self.appStore.lastState)")
            self.appStore.store(last: max(Int64(response.lastState), self.appStore.lastState))
        }
        updateListenStream?.status.whenComplete { status in
            self.isConnectedToListenStream = false
            switch status {
            case .success(let response):
                PP.debug("Update listen stream is completed with code - \(response.code); isOk - \(response.isOk); message - \(response.message); cause - \(response.cause)")
            case .failure(let error):
                PP.debug("Update listen stream is completed with error - \(error); localeError - \(error.localeError)")
            }
            
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
            guard message.shouldBeSaved else {
                return
            }
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
            self.conversationService.updateTransferStatus(status)
        case .stockTransferStatus(let data):
            PP.debug(data.textFormatString())
        case .coinTransferStatus(let data):
            PP.debug(data.textFormatString())
        case .chat(let chat):
            if chat.settings.callAllowed {
                self.conversationService
                    .update(callAllowed: chat.settings.callAllowed, id: chat.chatID)
                    .subscribe()
                    .disposed(by: disposeBag)
            }
            if chat.settings.addContact {
                self.conversationService
                    .update(addContact: chat.settings.addContact, id: chat.chatID)
                    .subscribe()
                    .disposed(by: disposeBag)
                
                self.chatInteractor
                    .executeSingle(params: chat.chatID)
                    .asObservable()
                    .flatMap { [weak self] chat in
                        guard let self = self else {
                            return Observable<[Void]>.empty()
                        }
                        let members = chat.members
                        let methods = members
                            .filter { $0.id != self.appStore.userID() }
                            .map(\.id)
                            .map { id in
                                return self.updateContactStatusInteractor.executeSingle(params: id).asObservable()
                            }
                        return Observable.zip(methods)
                    }
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .subscribe()
                    .disposed(by: disposeBag)
            }
        case .call:
            break
        }
    }
    
    func initializeSupportChats() {
        UltraCoreSettings.delegate?.getSupportChatsAndManagers(callBack: { [weak self] responseDict in
            guard let self = self else { return }
            PP.debug("Get support chats - \(responseDict)")
            do {
                let data = try JSONSerialization.data(withJSONObject: responseDict, options: .fragmentsAllowed)
                let response = try JSONDecoder().decode(SupportOfficesResponse.self, from: data)
                let request = InitSupportChatsRequest.with { req in
                    req.receptions = response.supportChats.map { supportChat in
                        InitSupportChatsRequest.Reception.with {
                            $0.name = supportChat.name
                            $0.reception = String(supportChat.reception)
                        }
                    }
                    req.managers = response.personalManagers.map { manager in
                        InitSupportChatsRequest.PersonalManager.with {
                            $0.name = manager.nickname
                            $0.phone = String(manager.userId)
                        }
                    }
                }
                PP.debug("Support manager request - \(request)")
                supportOfficesSubject.onNext(response)
                initSupportInteractor.executeSingle(params: request)
                    .asObservable()
                    .flatMap { [weak self] chatsResponse -> Observable<[Void]> in
                        guard let self else { return Observable.empty() }
                        PP.debug("Support manager response - \(chatsResponse.chats)")
                        let requests = chatsResponse.chats
                            .map { chat in
                                self.chatToConversationInteractor.executeSingle(
                                    params: .init(
                                        chat: chat,
                                        imagePath: response.supportChats.first(where: { $0.name == chat.title })?.avatarUrl
                                    )
                                )
                                .asObservable()
                            }
                        return Observable.zip(requests)
                    }
                    .subscribe { _ in
                        
                    } onError: { error in
                        PP.error(error.localeError)
                    }
                    .disposed(by: disposeBag)
            } catch {
                PP.error(error.localizedDescription)
            }
        })
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
