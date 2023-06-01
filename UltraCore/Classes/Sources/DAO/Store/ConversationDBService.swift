//
//  ConversationDBService.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import RxSwift
import RealmSwift

class ConversationDBService {
    
    fileprivate let userID: String
    
    init(userID: String) {
        self.userID = userID
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
                        conversation.peer = contact
                        conversation.lastSeen = message.meta.created
                        conversation.message = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) ?? DBMessage.init(from: message, realm: realm, user: self.userID)
                        realm.create(DBConversation.self, value: conversation, update: .all)
                    } else {
                        let conversation = realm.create(DBConversation.self,
                                                        value: DBConversation(message: message, user: self.userID))
                        conversation.peer = contact
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
                    observer.on(.next(Array(collection.map({DBConversation(value: $0)}))))
                case let .update(collection, _, _, _):
                    observer.on(.next(Array(collection.map({DBConversation(value: $0)}))))
                case let .error(error):
                    observer.on(.error(error))
                }
            }

            return Disposables.create { notificationKey.invalidate() }
        }
    }
    
    // Получение списка всех чатов
    func getConversations() -> Observable<[DBConversation]> {
        return Observable.deferred {
            let realm = try Realm()
            let conversations = Array(realm.objects(DBConversation.self).sorted(byKeyPath: "lastSeen", ascending: false))
            return Observable.just(conversations)
        }
    }
}


extension Message {
    func peerId(user id: String) -> String {
        return sender.userID == id ? receiver.userID : sender.userID
    }
}
