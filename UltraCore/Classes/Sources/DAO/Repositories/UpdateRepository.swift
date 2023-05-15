//
//  UpdateRepository.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import Foundation
import RxSwift

protocol UpdateRepository: AnyObject {
    func setupSubscription()
    func sendPoingByTimer()
}

class UpdateRepositoryImpl {
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
                    case let .success(response):
                        Logger.debug(response.textFormatString())
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
                        Logger.debug(message.textFormatString())
                    case let .messagesRead(message):
                        Logger.debug(message.textFormatString())
                    case let .messagesDeleted(message):
                        Logger.debug(message.textFormatString())
                    case let .chatDeleted(chat):
                        Logger.debug(chat.textFormatString())
                    case let .moneyTransferStatus(status):
                        Logger.debug(status.textFormatString())
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
        self.contactService.save(contact: DBContact.init(from: contact,user: self.appStore.userID()))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
            .dispose()
    }
}
