//
//  ContactDBService.swift
//  UltraCore
//
//  Created by Slam on 5/4/23.
//
import RxSwift
import RealmSwift

class ContactDBService {
    fileprivate let appStore: AppSettingsStore
    
    fileprivate var userID: String  {
        return self.appStore.userID()
    }
    
    init(appStore: AppSettingsStore) {
        self.appStore = appStore
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
            Realm.realmQueue.async {
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
            Realm.realmQueue.async {
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
            }
            return Disposables.create()
        }
    }
    
    func updateContact(status: UserStatusEnum) {
        Realm.realmQueue.async {
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.objects(DBContact.self).forEach { contact in
                        contact.statusValue = status.rawValue
                        realm.add(contact, update: .all)
                    }
                }
            } catch {
                PP.error(error.localizedDescription)
            }
        }
    }
    
    func update(contacts statuses: [UserStatus]) -> Single<[ContactDisplayable]> {
        return Single.create { completable in
            Realm.realmQueue.async {
                do {
                    let realm = Realm.myRealm()
                    try realm.write {
                        var listContact: [ContactDisplayable] = []
                        statuses.forEach { status in
                            if let contact = realm.object(ofType: DBContact.self, forPrimaryKey: status.userID) {
                                contact.statusValue = status.status.rawValue
                                contact.lastseen = status.lastSeen

                                realm.add(contact, update: .all)
                                listContact.append(contact.toInterface())
                            }
                        }
                        
                        completable(.success(listContact))
                    }
                } catch {
                    completable(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func save(contact interface: ContactDisplayable) -> Single<DBContact> {
        return Single.create { completable in
            Realm.realmQueue.async {
                do {
                    let realm = Realm.myRealm()
                    let contact = realm.object(ofType: DBContact.self, forPrimaryKey: interface.userID) ?? DBContact(contact: interface)
                    try realm.write {
                        if let contactInfo = UltraCoreSettings.delegate?.info(from: interface.phone) {
                            contact.lastname = contactInfo.lastname
                            contact.firstname = contactInfo.firstname
                            contact.imagePath = contactInfo.imagePath
                        }
                        
                        contact.isBlocked = interface.isBlocked
                        if interface.status.lastSeen > contact.lastseen {
                            contact.lastseen = interface.status.lastSeen
                            contact.statusValue = interface.status.status.rawValue
                        }
                        
                        realm.add(contact, update: .all)
                    }
                    completable(.success(contact))
                } catch {
                    completable(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func delete( contact: ContactDisplayable) -> Single<Void> {
        return Single.create { completable in
            Realm.realmQueue.async {
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
            }
            return Disposables.create()
        }
    }
    
    static func update(contacts: [IContactInfo]) {
        Realm.realmQueue.async {
            do {
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
            } catch {
                PP.error("Error on updating contacts - \(error.localizedDescription)")
            }
        }
    }
}
