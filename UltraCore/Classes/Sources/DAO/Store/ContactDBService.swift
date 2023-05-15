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
    
    func save(contacts: ContactImportResponse) -> Single<Void> {

        return Single.create {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            do {
                
                let dbContacts = contacts.contacts.map { contact -> DBContact in
                    return DBContact.init(from: contact,user: self.userID)
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
    
    func contacts() -> Observable<Results<DBContact>> {
        return Observable.create { observer in
            let realm = Realm.myRealm()
            let contacts = realm.objects(DBContact.self)
            let notificationKey = contacts.observe(keyPaths: ["firstName", "lastName", "phone", "userID"]) { changes in

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
    
    func contact(id: String) -> DBContact? {
        return Realm.myRealm().object(ofType: DBContact.self, forPrimaryKey: id)
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
