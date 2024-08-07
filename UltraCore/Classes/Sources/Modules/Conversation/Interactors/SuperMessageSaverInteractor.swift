//
//  SuperMessageSaverInteractor.swift
//  UltraCore
//
//  Created by Slam on 7/1/23.
//
import RxSwift
import Foundation

typealias MessageData = [AnyHashable: Any]

class SuperMessageSaverInteractor: UseCase<MessageData, Conversation?> {
    
    fileprivate let appStore: AppSettingsStore
    fileprivate let messageDBService: MessageDBService
    fileprivate let contactDBService: ContactDBService
    fileprivate let conversationDBService: ConversationDBService
    
    fileprivate let contactByUserIdInteractor: ContactByUserIdInteractor
    
    init(
        appStore: AppSettingsStore,
        contactDBService: ContactDBService,
        messageDBService: MessageDBService,
        conversationDBService: ConversationDBService
    ) {
        self.appStore = appStore
        self.contactDBService = contactDBService
        self.messageDBService = messageDBService
        self.conversationDBService = conversationDBService
        
        self.contactByUserIdInteractor = .init(delegate: UltraCoreSettings.delegate)
    }
    
    override func executeSingle(params: MessageData) -> Single<Conversation?> {
        guard let conversationID = params["chat_id"] as? String,
              let peerID = params["sender_id"] as? String else { return Single.error(NSError.objectsIsNill) }

        let contact = self.contactDBService.contact(id: peerID)
        if contact == nil {
            return self.contactByUserIdInteractor
                .executeSingle(params: peerID)
                .flatMap({ self.contactDBService.save(contact: $0) })
                .flatMap({ _ in self.messageDBService.lastMessage(chatID: conversationID)})
                .flatMap({ message in self.conversationDBService.createIfNotExist(from: message).map({message}) })
                .flatMap({ message in self.messageDBService.update(message: message) })
                .flatMap({_ in self.conversationDBService.conversation(by: conversationID)})
        } else {
            return self.messageDBService.lastMessage(chatID: conversationID)
                .flatMap({ message in self.conversationDBService.createIfNotExist(from: message).map({message}) })
                .flatMap({ message in self.messageDBService.update(message: message) })
                .flatMap({_ in self.conversationDBService.conversation(by: conversationID)})
        }
    }
}

