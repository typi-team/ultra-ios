//
//  UpdateRepository.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import Foundation
import RxSwift

struct UserTypingWithDate: Hashable {
    var chatId: String
    var userId: String
    var createdAt: Date
    
    init(chatId: String, userId: String, createdAt: Date = Date()) {
        self.chatId = chatId
        self.userId = userId
        self.createdAt = createdAt
    }
    
    
    init(user typing: UserTyping) {
        self.createdAt = Date()
        self.chatId = typing.chatID
        self.userId = typing.userID
    }
    
    var isTyping: Bool {
        return Date().timeIntervalSince(createdAt) < kTypingMinInterval
    }
    
    static func == (lhs: UserTypingWithDate, rhs: UserTypingWithDate) -> Bool {
        return lhs.chatId == rhs.chatId
    }
}

protocol UpdateRepository: AnyObject {
    func setupSubscription()
    func sendPoingByTimer()
    var typingUsers: BehaviorSubject<[String: UserTypingWithDate]> { get set }
}

class UpdateRepositoryImpl {
    
    var typingUsers: BehaviorSubject<[String: UserTypingWithDate]> = .init(value: [:])
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let appStore: AppSettingsStore
    fileprivate let contactService: ContactDBService
    fileprivate let messageService: MessageDBService
    fileprivate let update: UpdatesServiceClientProtocol
    fileprivate let conversationService: ConversationDBService
    fileprivate let contactByIDInteractor: UseCase<String, Contact>
    
    
    init(appStore: AppSettingsStore,
         messageService: MessageDBService,
         contactService: ContactDBService,
         update: UpdatesServiceClientProtocol,
         userByIDInteractor: UseCase<String, Contact>,
         conversationService: ConversationDBService) {
        self.update = update
        self.appStore = appStore
        self.messageService = messageService
        self.contactService = contactService
        self.contactByIDInteractor = userByIDInteractor
        self.conversationService = conversationService
    }
}

extension UpdateRepositoryImpl: UpdateRepository {
    func sendPoingByTimer() {
        Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { [weak self] timer in
            guard let `self` = self else { return timer.invalidate() }
            self.update.ping(PingRequest(), callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case .success:
                        break
                    case let .failure(error):
                        Logger.error(error.localizedDescription)
                        timer.invalidate()
                    }
                }
        }
    }
    
    func setupSubscription() {

        let state: ListenRequest = .with { $0.localState = .with { $0.state = UInt64(appStore.lastState) } }
        let call = self.update.listen(state, callOptions: .default()) { [weak self] response in
            guard let `self` = self else { return }
            self.appStore.store(last: Int64(response.lastState))
            response.updates.forEach { update in
                if let ofUpdate = update.ofUpdate {
                    switch ofUpdate {

                    case let .message(message):
                        self.update(message: message)
                    case let .contact(contact):
                        self.update(contact: contact)
                    case let .messagesDelivered(message):
                        self.messagesDelivered(message: message)
                    case let .messagesRead(message):
                        self.messagesReaded(message: message)
                    case let .messagesDeleted(message):
                        Logger.debug(message.textFormatString())
                    case let .chatDeleted(chat):
                        Logger.debug(chat.textFormatString())
                    case let .moneyTransferStatus(status):
                        Logger.debug(status.textFormatString())
                    }
                } else if let presence = update.ofPresence {
                    switch presence {
                    case let .typing(typing):
                        self.handle(user: typing)
                    case let .audioRecording(pres):
                        Logger.debug(pres.textFormatString())
                    case let .userStatus(userStatus):
                        guard var contact = self.contactService.contact(id: userStatus.userID)?.toProto() else {
                            return
                        }
                        contact.status = userStatus
                        self.update(contact: contact)

                    case let .mediaUploading(pres):
                        Logger.debug(pres.textFormatString())
                    }
                }
            }
        }
        call.status.whenComplete { status in
            print(status)
        }
    }
}

extension UpdateRepositoryImpl {
    func update(message: Message) {
        let contactID = message.peerId(user: self.appStore.userID())
        let contact = self.contactService.contact(id: contactID)
        if contact == nil {
            _ = self.contactByIDInteractor
                .executeSingle(params: contactID)
                .flatMap({ self.contactService.save(contact: DBContact(from: $0, user: self.appStore.userID())) })
                .flatMap({ _ in self.conversationService.createIfNotExist(from: message) })
                .flatMap({ self.messageService.update(message: message) })
                .subscribe()
                
        } else {
            self.conversationService
                .createIfNotExist(from: message)
                .flatMap({ self.messageService.update(message: message) })
                .subscribe()
                .dispose()
        }
    }
    func update(contact: Contact) {
        self.contactService.save(contact: DBContact.init(from: contact, user: self.appStore.userID()))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
            .dispose()
    }
}

extension UpdateRepositoryImpl {
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
            typingUsers.on(.next(users))
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
