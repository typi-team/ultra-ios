//
//  ContactDBService.swift
//  UltraCore
//
//  Created by Slam on 5/4/23.
//
import RxSwift
import RealmSwift

class ContactDBService {
    fileprivate let userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    func contacts() -> Observable<[Contact]> {
        return Observable.create { observer in
            let realm = Realm.myRealm()
            let contacts = realm.objects(DBContact.self)
            let notificationKey = contacts.observe(keyPaths: []) { changes in
                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection.map({$0.toProto()})))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection.map({$0.toProto()})))
                case let .error(error):
                    observer.on(.error(error))
                }
            }
            return Disposables.create {
                notificationKey.invalidate()
            }
        }
    }
    
    func block(user id: String, blocked: Bool) -> Single<Void> {
        Single.create { observer in
            do {
                let realm = Realm.myRealm()
                try realm.write({
                    if let contact = realm.object(ofType: DBContact.self, forPrimaryKey: id) {
                        contact.isBlocked = blocked
                        realm.add(contact, update: .all)
                    }

                    observer(.success(()))
                })
            } catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func contact(id: String) -> DBContact? {
        if let contact = Realm.myRealm().object(ofType: DBContact.self, forPrimaryKey: id) {
            return DBContact(value: contact)
        }
        return nil
    }
    
    func save( contact: DBContact) -> Single<Void> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.add(contact, update: .all)
                }
                completable(.success(()))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func delete( contact: DBContact) -> Single<Void> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.delete(contact)
                }
                completable(.success(()))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func update(contacts: [IContactInfo]) throws {
        let realm = Realm.myRealm()
        try realm.write {
            PP.info(realm.objects(DBContact.self).map{"\($0.phone) \($0.firstName)"}.joined(separator: "\n"))
            realm.objects(DBContact.self).forEach { storedContact in
                if let contact = contacts.first(where: { $0.userID == storedContact.userID }) {
                    storedContact.firstName = contact.firstname
                    storedContact.lastName = contact.lastname
                    realm.add(storedContact, update: .all)
                }
            }
        }
    }
}

extension Contact: IContactInfo {
    
}
