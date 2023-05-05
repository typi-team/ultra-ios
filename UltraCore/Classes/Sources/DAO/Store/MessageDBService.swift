//
//  MessageService.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import RxSwift
import RealmSwift

class MessageDBService {

//  MARK: Обновление сообщения в базе данных
    func update(message: Message) -> Single<Bool> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.create(DBMessage.self, value: DBMessage(from: message), update: .all)
                }

                completable(.success(true))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }

//   MARK: Получение всех сообщений в чате
    func messages(chatID: String) -> Observable<RealmSwift.Results<DBMessage>> {
        return Observable.create { observer in
            let realm = Realm.myRealm()
            let contacts = realm.objects(DBMessage.self).where { $0.receiver.chatID.equals(chatID) }
            let notificationKey = contacts.observe(keyPaths: []) { changes in
                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection))
                case let .error(error):
                    observer.on(.error(error))
                }
            }
            
            observer.onNext(contacts)
            return Disposables.create {
                notificationKey.invalidate()
            }
        }
    }
    
//    MARK: Сохранение сообщения в базу данных
    func save(message: Message) -> Single<Void> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.create(DBMessage.self, value: DBMessage(from: message), update: .all)
                    
                }
                completable(.success(()))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
}
