//
//  ChatToConversationInteractor.swift
//  UltraCore
//
//  Created by Typi on 13.05.2024.
//

import Foundation
import RxSwift
import RealmSwift

struct ChatToConversationParams {
    let chat: Chat
    let imagePath: String?
}

class ChatToConversationInteractor: GRPCErrorUseCase<ChatToConversationParams, Void> {
    
    private let contactByUserIdInteractor: ContactByUserIdInteractor
    private let contactDBService: ContactDBService
    private let disposeBag = DisposeBag()
    
    init(contactByUserIdInteractor: ContactByUserIdInteractor, contactDBService: ContactDBService) {
        self.contactByUserIdInteractor = contactByUserIdInteractor
        self.contactDBService = contactDBService
    }
    
    override func executeSingle(params: ChatToConversationParams) -> Single<Void> {
        let realm = Realm.myRealm()
        if let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: params.chat.chatID) {
            do {
                try realm.write {
                    conversation.imagePath = params.imagePath ?? ""
                    conversation.title = params.chat.title
                    PP.debug("Saving imagepath - \(params.imagePath); title - \(params.chat.title) for existing chatID - \(params.chat.chatID)")
                    realm.create(DBConversation.self, value: conversation, update: .all)
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }
        
        let requests = params.chat.members
            .map { $0.id }
            .filter {
                $0 != AppSettingsImpl.shared.appStore.userID()
            }
            .map { self.contactByUserIdInteractor.executeSingle(params: $0).asObservable() }
        return Observable.zip(requests)
            .flatMap { [weak self] contacts -> Observable<[DBContact]> in
                guard let self = self else {
                    return Observable.empty()
                }
                PP.debug("Got contacts - \(contacts.map { "\($0.firstname) \($0.lastname) \($0.phone)" }) for chatID - \(params.chat.chatID) chatTitle - \(params.chat.title)")
                let contactRequests = contacts.map {
                    self.contactDBService.save(contact: $0).asObservable()
                }
                return Observable.zip(contactRequests)
            }
            .flatMap { contacts -> Observable<Void> in
                let localRealm = Realm.myRealm()
                if let conversation = localRealm.object(ofType: DBConversation.self, forPrimaryKey: params.chat.chatID) {
                    do {
                        try localRealm.write {
                            conversation.imagePath = params.imagePath ?? ""
                            conversation.title = params.chat.title
                            localRealm.create(DBConversation.self, value: conversation, update: .all)
                        }
                        return .just(())
                    } catch {
                        return .error(error)
                    }
                }
                do {
                    try localRealm.write {
                        let conv = ConversationImpl(
                            title: params.chat.title,
                            contacts: contacts.map { $0.toInterface() },
                            idintification: params.chat.chatID,
                            addContact: params.chat.settings.addContact,
                            seqNumber: params.chat.messageSeqNumber,
                            callAllowed: params.chat.settings.callAllowed
                        )
                        let conversation = localRealm.create(DBConversation.self, value: DBConversation(conversation: conv, contacts: contacts))
                        conversation.conversationType = params.chat.chatType.rawValue
                        conversation.imagePath = params.imagePath ?? ""
                        if params.chat.properties["is_assistant"] == "true" {
                            conversation.isAssistant = true
                        }
                        PP.debug("Saving imagepath - \(params.imagePath); title - \(params.chat.title) for new chatID - \(params.chat.chatID)")
                    }
                    return .just(())
                } catch {
                    return .error(error)
                }
            }
            .asSingle()

    }
    
}
