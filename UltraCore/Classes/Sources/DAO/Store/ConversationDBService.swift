//
//  ConversationDBService.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import RxSwift
import RealmSwift

class ConversationDBService {
    
    fileprivate let appStore: AppSettingsStore
    
    fileprivate var userID: String  {
        return self.appStore.userID()
    }
    
    init(appStore: AppSettingsStore) {
        self.appStore = appStore
        UnreadMessagesService.updateUnreadMessagesCount()
    }
    
    func createIfNotExist(from message: Message) -> Single<Void> {
        return Single.create {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            do {
                let realm = Realm.myRealm()
                try realm.write({
                    let peerID = message.peerId(user: self.userID)
                    let contact = realm.object(ofType: DBContact.self, forPrimaryKey: peerID )
                    let existConversation = realm.object(ofType: DBConversation.self, forPrimaryKey: message.receiver.chatID)
                    if let conversation = existConversation {
                        conversation.contact = contact
                        conversation.lastSeen = message.meta.created
                        conversation.message = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) ?? DBMessage.init(from: message, realm: realm, user: self.userID)
                        realm.create(DBConversation.self, value: conversation, update: .all)
                    } else {
                        let conversation = realm.create(DBConversation.self,
                                                        value: DBConversation(message: message, user: self.userID))
                        conversation.contact = contact
                        realm.add(conversation)
                    }
                    
                })
                observer(.success(()))
                
            } catch let exception {
                observer(.failure(exception))
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
        do {
            let realm = Realm.myRealm()
            try realm.write {
                if let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: conversationID) {
                    conversation.unreadMessageCount += count
                    realm.add(conversation, update: .all)
                    UnreadMessagesService.updateUnreadMessagesCount()
                }
            }
            return true
        } catch {
            return false
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
                    UnreadMessagesService.updateUnreadMessagesCount()
                }
            }
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
