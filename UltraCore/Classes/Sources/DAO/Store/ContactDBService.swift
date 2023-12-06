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
    
    func contacts() -> Observable<[ContactDisplayable]> {
        return Observable.create { observer in
            let realm = Realm.myRealm()
            let contacts = realm.objects(DBContact.self)
            let notificationKey = contacts.observe(keyPaths: []) { changes in
                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection.map({$0.toInterface()})))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection.map({$0.toInterface()})))
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
    
    func contact(id: String) -> ContactDisplayable? {
        if let contact = Realm.myRealm().object(ofType: DBContact.self, forPrimaryKey: id) {
            return DBContact(value: contact).toInterface()
        }
        return nil
    }
    
    func update(contact status: UserStatus) -> Single<ContactDisplayable> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    if let contact = realm.object(ofType: DBContact.self, forPrimaryKey: status.userID) {
                        contact.statusValue = status.status.rawValue
                        contact.lastseen = status.lastSeen

                        realm.add(contact, update: .all)
                        completable(.success(contact.toInterface()))
                    } else {
                        completable(.failure(NSError.objectsIsNill))
                    }
                }
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func save(contact interface: ContactDisplayable) -> Single<Void> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    let contact = DBContact(contact: interface)
                    if let contactInfo = UltraCoreSettings.delegate?.info(from: interface.phone) {
                        contact.lastname = contactInfo.lastname
                        contact.firstname = contactInfo.firstname
                        contact.imagePath = contactInfo.imagePath
                    }
                    realm.add(contact, update: .all)
                    
                }
                completable(.success(()))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func delete( contact: ContactDisplayable) -> Single<Void> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    if let existContact = realm.object(ofType: DBContact.self, forPrimaryKey: contact.userID) {
                        realm.delete(existContact)
                    }
                    completable(.success(()))
                }
                
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func update(contacts: [IContactInfo]) throws {
        let realm = Realm.myRealm()
        try realm.write {
            realm.objects(DBContact.self).forEach { storedContact in
                if let contact = contacts.first(where: { $0.identifier == storedContact.phone }) {
                    storedContact.firstname = contact.firstname
                    storedContact.lastname = contact.lastname
                    storedContact.imagePath = contact.imagePath
                    realm.add(storedContact, update: .all)
                }
            }
        }
    }
}
