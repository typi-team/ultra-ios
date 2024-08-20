//
//  MessageService.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import RxSwift
import RealmSwift

class MessageDBService {
    fileprivate let appStore: AppSettingsStore
    
    fileprivate var userID: String  {
        return self.appStore.userID()
    }
    
    init(appStore: AppSettingsStore) {
        self.appStore = appStore
    }

//  MARK: Обновление сообщения в базе данных
    func update(message: Message) -> Single<Bool> {
        PP.debug("[Message] [DB message update]: \(message.id)")
        return Single.create {[weak self ] completable in
            guard let `self` = self else { return Disposables.create() }
            Realm.realmQueue.async {
                do {
                    guard let realm = Realm.myRealm() else {
                        completable(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                        return
                    }
                    try realm.write {
                        if let messageInDB = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) {
                            messageInDB.state?.read = message.state.read
                            messageInDB.state?.edited = message.state.edited
                            messageInDB.state?.delivered = message.state.delivered
                            messageInDB.seqNumber = Int64(message.seqNumber)
                            PP.debug("[Message] [DB message update]: update \(message.id)")
                        } else {
                            realm.create(DBMessage.self,
                                         value: DBMessage(from: message, user: self.userID), update: .all)
                            PP.debug("[Message] [DB message update]: created & saved \(message.id)")
                        }
                        
                    }

                    completable(.success(true))
                } catch {
                    PP.error("[Message] [DB message update]: Failed to save message \(message.id)")
                    completable(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    //  MARK: Обновить сообщения как доставлено в базе данных
    func delivered(message data: MessagesDelivered) -> Single<Bool> {
        return Single.create { completable in
            Realm.realmQueue.async {
                do {
                    guard let realm = Realm.myRealm() else {
                        completable(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                        return
                    }
                    try realm.write {
                        let messagesInDB = realm.objects(DBMessage.self)
                            .where({ $0.receiver.chatID.equals(data.chatID) })
                            .where({ $0.seqNumber <= Int64(data.maxSeqNumber) })
                        messagesInDB.forEach { message in
                            message.state?.delivered = true
                        }
                    }
                    PP.debug("Marking messages before \(data.maxSeqNumber) in chat \(data.chatID) as delivered")
                    completable(.success(true))
                } catch {
                    PP.error("Failed to mark messages for chatID \(data.chatID) as delivered")
                    completable(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    //  MARK: Обновить сообщения как прочитанный в базе данных
    func readed(message data: MessagesRead) -> Single<Bool> {
        return Single.create { completable in
            Realm.realmQueue.async {
                do {
                    guard let realm = Realm.myRealm() else {
                        completable(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                        return
                    }
                    try realm.write {
                        let messagesInDB = realm.objects(DBMessage.self)
                            .where({ $0.receiver.chatID.equals(data.chatID) })
                            .where({ $0.seqNumber <= Int64(data.maxSeqNumber) })
                        messagesInDB.forEach { message in
                            message.state?.read = true
                            message.state?.delivered = true
                        }
                        if let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: data.chatID) {
                            conversation.unreadMessageCount = realm.objects(DBMessage.self)
                                .where({ $0.receiver.chatID.equals(data.chatID) })
                                .filter { $0.sender?.userID != self.appStore.userID() }
                                .filter { $0.state?.read == false }
                                .count
                        }
                    }
                    PP.debug("Marking messages before \(data.maxSeqNumber) in chat \(data.chatID) as read")
                    completable(.success(true))
                } catch {
                    PP.error("Failed to mark messages for chatID \(data.chatID) as read")
                    completable(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

//   MARK: Получение всех сообщений в чате
    func messages(chatID: String) -> Observable<[Message]> {
        return Observable.create { observer in
            guard let realm = Realm.myRealm() else {
                observer.onError(UltraCoreSettings.realmError ?? NSError.objectsIsNill)
                return Disposables.create()
            }
            let messages = realm.objects(DBMessage.self).where { $0.receiver.chatID.equals(chatID) }
            let notificationKey = messages.observe(keyPaths: ["id", "text", "systemActionType", "state.read", "state.delivered", "state.edited", "callMessage.status"]) { changes in
                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection.map({$0.toProto()})))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection.map({$0.toProto()})))
                case let .error(error):
                    observer.on(.error(error))
                }
            }
            
            observer.onNext(messages.map({$0.toProto()}))
            return Disposables.create {
                notificationKey.invalidate()
            }
        }
    }
    
    func lastMessage(chatID: String) -> Single<Message> {
        return Single.create { completable in
            guard let realm = Realm.myRealm() else {
                completable(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                return Disposables.create()
            }
            let messages = (realm.objects(DBMessage.self).where { $0.receiver.chatID.equals(chatID) })
                                        .compactMap { $0.toProto() }.sorted(by: { m1, m2 in m1.meta.created < m2.meta.created })
            if let lastMessage = messages.last {
                completable(.success(lastMessage))
            } else {
                completable(.failure(NSError.objectsIsNill))
            }
            return Disposables.create()
        }
    }
    
    //   MARK: Получение всех сообщений в базе
    func messages() -> Observable<[Message]> {
        return Observable.create { observer in
            guard let realm = Realm.myRealm() else {
                observer.onError(UltraCoreSettings.realmError ?? NSError.objectsIsNill)
                return Disposables.create()
            }
            let messages = realm.objects(DBMessage.self)
            observer.onNext(messages.map({$0.toProto()}))
            return Disposables.create()
        }
    }
    
    func message(id: String) -> Message? {
        guard let realm = Realm.myRealm() else {
            return nil
        }
        guard let message = realm.objects(DBMessage.self)
            .map({ $0.toProto() })
            .first(where: { $0.id == id }) else {
            return nil
        }
        
        return message
    }
    
//    MARK: Сохранение сообщения в базу данных
    func save(message: Message) -> Single<Void> {
        PP.debug("[Message] [DB message save]: \(message)")
        return Single.create {[weak self] completable in
            guard let `self` = self else {
                completable(.failure(NSError.objectsIsNill))
                return Disposables.create()
            }
            Realm.realmQueue.async {
                do {
                    guard let realm = Realm.myRealm() else {
                        completable(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                        return
                    }
                    try realm.write {
                        realm.create(DBMessage.self,
                                     value: DBMessage(from: message, user: self.userID), update: .all)
                        
                    }
                    PP.debug("[Message] [DB message save]: successfully saved \(message.id)")
                    completable(.success(()))
                } catch {
                    PP.debug("[Message] [DB message save]: Failed to save \(message.id) \(error)")
                    completable(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    /// Удаление сообщения
    /// - Parameter messages: Массив сообщений, важно: если сообщение последние в DBConversation то выставиться последнее что не удалено или пустота 
    /// - Returns: Void
    func delete(messages: [Message], in conversationID: String?) -> Single<Void> {
        return Single.create(subscribe: { observer -> Disposable in
            Realm.realmQueue.async {
                do {
                    guard let realm = Realm.myRealm() else {
                        observer(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                        return
                    }
                    try realm.write {
                        let notReadMessagesCount = messages.filter { $0.isIncome && $0.state.read == false }.count
                        self.decreaseUnreadMessagesCount(in: conversationID, on: realm, count: notReadMessagesCount)
                        messages.forEach { message in
                            let dbMessage = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id)
                            if let dbMessage = dbMessage {
                                realm.delete(dbMessage)
                            }
                        }
                        self.updateLastMessage(in: conversationID, on: realm)
                    }
                    observer(.success(()))
                } catch {
                    observer(.failure(error))
                }
            }
            return Disposables.create()
        })
    }
    
    func updateLastMessage(in conversationID: String?, on realm: Realm) {
        if let conversationID = conversationID,
                    let conversaiton = realm.object(ofType: DBConversation.self, forPrimaryKey: conversationID),
           conversaiton.message == nil {
            conversaiton.message = realm.objects(DBMessage.self)
                .where({$0.receiver.chatID == conversationID})
                .sorted(by: { $0.meta?.created ?? 0 < $1.meta?.created ?? 0 })
                .last
        }
    }
    
    func decreaseUnreadMessagesCount(in conversationID: String?, on realm: Realm, count: Int) {
        guard
            let conversationID,
            let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: conversationID)
        else { return }
        if conversation.unreadMessageCount - count >= 0 {
            conversation.unreadMessageCount -= count
        } else {
            conversation.unreadMessageCount = 0
        }
        AppSettingsImpl.shared.updateRepository.triggerUnreadUpdate()
    }
    
    func deleteMessages(in conversationID: String, ranges: [ClosedRange<Int64>]) -> Single<Void> {
        PP.debug("Attempt to delete messages in conversationID - \(conversationID) - \(ranges)")
        return Single.create(subscribe: {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            Realm.realmQueue.async {
                do {
                    guard let realm = Realm.myRealm() else {
                        observer(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                        return
                    }
                    try realm.write {
                        let messages = realm.objects(DBMessage.self)
                            .filter({ $0.receiver?.chatID == conversationID })
                            .filter({ self.isInRanges(number: Int64($0.seqNumber), ranges: ranges) })
                        PP.debug("Messages to delete - \((messages.compactMap { $0 } as [DBMessage]).map { $0.seqNumber })")
                        let notReadMessagesCount = messages.filter { $0.isIncome && $0.state?.read == false }.count
                        self.decreaseUnreadMessagesCount(in: conversationID, on: realm, count: notReadMessagesCount)
                        messages.forEach({ realm.delete($0) })
                        self.updateLastMessage(in: conversationID, on: realm)
                    }
                    observer(.success(()))
                } catch {
                    observer(.failure(error))
                }
            }

            return Disposables.create()
        })
    }
    
    func updateCall(_ call: Call) {
        let realm = Realm.myRealm()
        if let callDB = realm.object(ofType: DBCallMessage.self, forPrimaryKey: call.room),
           let dbMessage = realm.objects(DBMessage.self).first(where: { $0.callMessage?.room == call.room })
        {
            do {
                try realm.write {
                    callDB.endTime = call.endTime
                    callDB.startTime = call.startTime
                    callDB.status = call.status.rawValue
                }
            }
            catch {
                PP.error("Failed to update call - \(call)")
            }
        }
    }
    
    func save(messages: [Message]) -> Single<Void> {
        let messages = messages.filter { $0.shouldBeSaved }
        PP.debug("[Message] [DB MESSAGES save]: \(messages)")
        return Single.create {[weak self] completable in
            guard let `self` = self else { return Disposables.create() }
            Realm.realmQueue.async {
                do {
                    guard let realm = Realm.myRealm() else {
                        completable(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                        return
                    }
                    try realm.write {
                        messages.forEach { message in
                            realm.create(DBMessage.self,
                                         value: DBMessage(from: message, user: self.userID), update: .all)
                        }
                        
                    }
                    PP.debug("[Message] [DB MESSAGES save] Messages \(messages.map(\.id)) were saved")
                    completable(.success(()))
                } catch {
                    PP.debug("[Message] [DB MESSAGES save] Messages \(messages.map(\.id)) weren't saved \(error)")
                    completable(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}

private extension MessageDBService {
    func isInRanges(number: Int64, ranges: [ClosedRange<Int64>]) -> Bool {
        for range in ranges {
            if range.contains(number) {
                return true
            }
        }
        return false
    }
}
