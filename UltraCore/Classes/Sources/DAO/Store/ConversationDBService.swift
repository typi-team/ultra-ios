//
//  ConversationDBService.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import RxSwift
import RealmSwift

class ConversationDBService {
    
    enum ConversationError: Error {
        case notFound
    }
    
    fileprivate let appStore: AppSettingsStore
    fileprivate lazy var chatService: ChatServiceClientProtocol = AppSettingsImpl.shared.conversationService
    fileprivate lazy var callAllowedSubject = PublishSubject<(String, Bool)>()
    
    var callAllowedObservable: Observable<(String, Bool)> {
        callAllowedSubject
            .asObservable()
            .share(replay: 1)
    }
    
    fileprivate var userID: String  {
        return self.appStore.userID()
    }
    
    init(appStore: AppSettingsStore) {
        self.appStore = appStore
        self.chatService = chatService
        UnreadMessagesService.updateUnreadMessagesCount()
    }
    
    func createIfNotExist(from message: Message) -> Single<Void> {
        return Single.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            let realm = Realm.myRealm()
            let peerID = message.peerId(user: self.userID)
            let contact = realm.object(ofType: DBContact.self, forPrimaryKey: peerID )
            let existConversation = realm.object(ofType: DBConversation.self, forPrimaryKey: message.receiver.chatID)
            if let conversation = existConversation {
                do {
                    try realm.write {
                        conversation.contact = contact
                        conversation.lastSeen = message.meta.created
                        conversation.message = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) ?? DBMessage.init(from: message, realm: realm, user: self.userID)
                        if message.sender.userID != self.appStore.userID() {
                            conversation.unreadMessageCount += 1
                        }
                        realm.create(DBConversation.self, value: conversation, update: .all)
                    }
                    observer(.success(()))
                } catch {
                    observer(.failure(error))
                }
            } else {
                let request = GetChatSettingsRequest.with {
                    $0.id = message.receiver.chatID
                }
                self.chatService
                    .getSettings(request, callOptions: .default())
                    .response
                    .whenComplete { result in
                        switch result {
                        case .success(let response):
                            do {
                                let localRealm = Realm.myRealm()
                                let peerID = message.peerId(user: self.userID)
                                let contact = localRealm.object(ofType: DBContact.self, forPrimaryKey: peerID)
                                try localRealm.write {
                                    let conversation = localRealm.create(
                                        DBConversation.self,
                                        value: DBConversation(
                                            message: message,
                                            user: self.userID,
                                            addContact: response.settings.addContact, 
                                            callAllowed: response.settings.callAllowed
                                        )
                                    )
                                    conversation.contact = contact
                                    if message.sender.userID != self.appStore.userID() {
                                        conversation.unreadMessageCount += 1
                                    }
                                    localRealm.add(conversation)
                                }
                                observer(.success(()))
                            } catch {
                                observer(.failure(error))
                            }
                        case .failure(let error):
                            observer(.failure(error))
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    func conversations() -> Observable<[Conversation]> {
        return Observable.create { observer -> Disposable in
            let realm = Realm.myRealm()
            let messages = realm.objects(DBConversation.self)
            let results = messages
                .sorted(byKeyPath: "lastSeen", ascending: false)
            let notificationKey = results.observe(keyPaths: []) { changes in
                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection.map({ConversationImpl(dbConversation: $0)})))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection.map({ConversationImpl(dbConversation: $0)})))
                case let .error(error):
                    observer.on(.error(error))
                }
            }

            return Disposables.create { notificationKey.invalidate() }
        }
    }
    
    @discardableResult
    func incrementUnread(for conversationID: String, count: Int = 1) -> Bool {
        PP.debug("Trying to increment unread for conversationID - \(conversationID)")
        do {
            let realm = Realm.myRealm()
            try realm.write {
                if let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: conversationID) {
                    PP.debug("Incremented unread for conversationID - \(conversationID)")
                    conversation.unreadMessageCount += count
                    realm.add(conversation, update: .all)
                }
            }
            return true
        } catch {
            return false
        }
    }
    
    func setUnread(for conversationID: String, count: Int) {
        PP.debug("Trying to set unread for conversationID - \(conversationID)")
        do {
            let realm = Realm.myRealm()
            try realm.write {
                if let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: conversationID) {
                    PP.debug("Set unread for conversationID - \(conversationID)")
                    conversation.unreadMessageCount = count
                    realm.add(conversation, update: .all)
                }
            }
        } catch {
            PP.debug("Error on setting unread - \(error)")
        }
    }
    
    @discardableResult
    func readAllMessage(for conversationID: String) -> Bool {
        do {
            let realm = Realm.myRealm()
            try realm.write {
                if let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: conversationID) {
                    conversation.unreadMessageCount = 0
                    realm.add(conversation, update: .all)
                }
            }
            UnreadMessagesService.updateUnreadMessagesCount()
            return true
        } catch {
            return false
        }
    }

    func conversation(by id: String) -> Single<Conversation?> {
        return Single.deferred {
            let realm = Realm.myRealm()
            if let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: id) {
                return Single.just(conversation.toConversation())
            } else {
                return Single.just(nil)
            }
        }
    }
    
    func update(addContact: Bool, id: String) -> Single<Void> {
        return Single.create { single in
            let realm = Realm.myRealm()
            guard let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: id) else {
                single(.failure(ConversationError.notFound))
                return Disposables.create()
            }
            do {
                try realm.write {
                    conversation.addContact = addContact
                    realm.add(conversation, update: .all)
                }
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func update(callAllowed: Bool, id: String) -> Single<Void> {
        callAllowedSubject.onNext((id, callAllowed))
        return Single.create { single in
            let realm = Realm.myRealm()
            let conversations = realm.objects(DBConversation.self)
            guard let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: id) else {
                single(.failure(ConversationError.notFound))
                return Disposables.create()
            }
            do {
                try realm.write {
                    conversation.callAllowed = callAllowed
                    realm.add(conversation, update: .all)
                }
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func delete(conversation id: String) -> Single<Void> {
        return Single.create(subscribe: {observer in
            do {
                let realm = Realm.myRealm()
                try realm.write({
                    if let dbConv = realm.object(ofType: DBConversation.self, forPrimaryKey: id) {
                        realm.delete(dbConv)
                    }
                    
                    let messages = realm.objects(DBMessage.self).where({$0.receiver.chatID == id })
                    messages.forEach({ realm.delete($0)})
                })
                
            } catch {
                observer(.failure(error))
            }
            return Disposables.create()
            
        })
    }
}


extension Message {
    func peerId(user id: String) -> String {
        return sender.userID == id ? receiver.userID : sender.userID
    }
    
    var isIncome: Bool { self.receiver.userID == AppSettingsImpl.shared.appStore.userID() }
    
    var message: String? {
        content?.description ?? text
    }
    
    var statusImage: UIImage? {
        if self.seqNumber == 0 {
            return UltraCoreStyle.outcomeMessageCell?.loadingImage?.image ?? UIImage.named("conversation_status_loading")
        } else if self.state.delivered == false && self.state.read == false {
            return UltraCoreStyle.outcomeMessageCell?.sentImage?.image ?? UIImage.named("conversation_status_sent")
        } else if self.state.delivered == true && self.state.read == false {
            return UltraCoreStyle.outcomeMessageCell?.deliveredImage?.image ?? UIImage.named("conversation_status_delivered")
        } else {
            return UltraCoreStyle.outcomeMessageCell?.readImage?.image ?? UIImage.named("conversation_status_read")
            
        }
    }
    
    var stateViewWidth: Double {
        if let size = UltraCoreStyle.outcomeMessageCell?.statusWidth {
          return size
        } else if self.seqNumber == 0 {
            return 12
        } else if self.state.delivered == false && self.state.read == false {
            return 10
        } else if self.state.delivered == true && self.state.read == false {
            return 15
        } else {
            return 15
        }
    }
}
