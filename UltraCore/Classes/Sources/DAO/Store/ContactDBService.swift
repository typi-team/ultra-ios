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
    
    func contact(id: String) -> DBContact? {
        return Realm.myRealm().object(ofType: DBContact.self, forPrimaryKey: id)
    }
    
    func save(contacts: [IContact]) -> Single<Void> {
        return Single.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            do {
                let dbContacts = contacts.compactMap({$0 as? Contact})
                    .map { contact -> DBContact in
                    DBContact(from: contact, user: self.userID)
                }

                let realm = Realm.myRealm()
                try realm.write {
                    dbContacts.forEach {
                        realm.create(DBContact.self, value: $0, update: .all)
                    }
                }
                observer(.success(()))
            } catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
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
}
