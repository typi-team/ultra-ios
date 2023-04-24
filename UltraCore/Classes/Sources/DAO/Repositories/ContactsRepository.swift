//
//  ContactsRepository.swift
//  UltraCore
//
//  Created by Slam on 4/24/23.
//
import Realm
import RealmSwift
import RxSwift
import RxDataSources

import Foundation

protocol ContactsRepository {
    func contacts() -> Observable<Results<DBContact>>
    func contact(id: String) -> Single<DBContact?>
    func save(contact: DBContact) -> Completable
    func save(contacts: ContactResponse) -> Completable
    func delete(contact: DBContact) -> Completable
}


class ContactsRepositoryImpl: ContactsRepository {
    
    init() {
        let realm = Realm.myRealm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func save(contacts: ContactResponse) -> Completable {
        let dbContacts = contacts.contacts.map { contact -> DBContact in
            return DBContact { dbContact in
                dbContact.phone = contact.phone
                dbContact.userID = contact.userID
                dbContact.lastName = contact.lastname
                dbContact.firstName = contact.firstname
            }
        }

        return Completable.create { observer -> Disposable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    dbContacts.forEach {
                        realm.create(DBContact.self, value: $0, update: .all)
                    }
                }
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func contacts() -> Observable<Results<DBContact>> {
        return Observable.create { observer in
            let realm = Realm.myRealm()
            let contacts = realm.objects(DBContact.self)
            var notificationKey = contacts.observe(keyPaths: ["firstName", "lastName", "phone", "userID"]) { changes in

                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection))
                case let .error(error):
                    observer.on(.error(error))
                }
            }
            return Disposables.create {
                notificationKey.invalidate()
            }
        }
    }
    
    func contact(id: String) -> Single<DBContact?> {
        let realm = Realm.myRealm()
        guard let contact = realm.object(ofType: DBContact.self, forPrimaryKey: id) else {
            return Single.error(NSError(domain: "ContactsRepository", code: 404, userInfo: nil))
        }
        return Single.just(contact)
    }
    
    func save( contact: DBContact) -> Completable {
        return Completable.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.add(contact, update: .all)
                }
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func delete( contact: DBContact) -> Completable {
        return Completable.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.delete(contact)
                }
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
}

extension Realm {
    static func myRealm() -> Realm {
        let realmURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("UltraCore.realm")

        let config = Realm.Configuration(fileURL: realmURL)

        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch let error as NSError {
            print("Error opening realm: \(error.localizedDescription)")
            return try! Realm() // если ошибка, то создаем объект Realm с настройками по умолчанию
        }
    }
}
