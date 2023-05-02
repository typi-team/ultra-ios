//
//  ConversationRepository.swift
//  UltraCore
//
//  Created by Slam on 5/2/23.
//

import RxSwift
import RealmSwift

protocol ConversationRepository {
    func createIfNotExist(from message: Message) -> Completable
    func conversations() -> Observable<Results<DBConversation>>
}

class ConversationRepositoryImpl {
    fileprivate let appStore: AppSettingsStore
    
    init(appStore: AppSettingsStore) {
        self.appStore = appStore
        
        Logger.debug(Realm.myRealm().configuration.fileURL?.absoluteString ?? "Realm path is't create")
    }
}

extension ConversationRepositoryImpl: ConversationRepository {
    func createIfNotExist(from message: Message) -> Completable {
        return Completable.create {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            do {
                let realm = Realm.myRealm()
                try realm.write({
                    
                    let isIncoming = message.receiver.userID == self.appStore.userID()
                    let contact = realm.object(ofType: DBContact.self, forPrimaryKey: isIncoming ? message.receiver.userID : message.sender.userID)
                    let existConversation = realm.object(ofType: DBConversation.self, forPrimaryKey: message.receiver.chatID)
                    if let conversation = existConversation {
                        conversation.peer = contact
                        conversation.lastSeen = message.meta.created
                        conversation.message = DBMessage.init(from: message, realm: realm)
                        realm.create(DBConversation.self, value: conversation, update: .all)
                    } else {
                        let conversation = realm.create(DBConversation.self, value: DBConversation(message: message))
                        conversation.peer = contact
                        realm.add(conversation)
                    }
                    observer(.completed)
                })
                
            } catch let exception {
                observer(.error(exception))
            }
            return Disposables.create()
        }
    }
    
    func conversations() -> Observable<Results<DBConversation>> {
        return Observable.create { observer -> Disposable in
            let realm = Realm.myRealm()
            let messages = realm.objects(DBConversation.self)
            let results = messages
                .sorted(byKeyPath: "lastSeen", ascending: false)
            let notificationKey = results.observe(keyPaths: []) { changes in
                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection))
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
