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
    func contacts() -> Observable<[ContactDisplayable]>
    func contact(id: String) -> ContactDisplayable?
    func save(contact: ContactDisplayable) -> Single<DBContact>
    func delete(contact: ContactDisplayable) -> Single<Void>
    func block(user id: String, blocked: Bool) -> Single<Void>
}


class ContactsRepositoryImpl: ContactsRepository {

    fileprivate let contactDBService: ContactDBService
    
    init(contactDBService: ContactDBService) {
        self.contactDBService = contactDBService
    }
    
    func contacts() -> Observable<[ContactDisplayable]> {
        return self.contactDBService.contacts()
    }
    
    func contact(id: String) -> ContactDisplayable? {
        return self.contactDBService.contact(id: id)
    }
    
    func save(contact: ContactDisplayable) -> Single<DBContact> {
        return self.contactDBService.save(contact: contact)
    }
    
    func delete(contact: ContactDisplayable) -> Single<Void> {
        return self.contactDBService.delete(contact: contact)
    }
    
    func block(user id: String, blocked: Bool) -> Single<Void> {
        return self.contactDBService.block(user: id, blocked: blocked)
    }
}

extension Realm {
    static func myRealm() -> Realm? {
        let realmURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Ultra-Core2.realm")

        var config = Realm.Configuration(
            fileURL: realmURL,
            schemaVersion: 2
        )
        config.objectTypes = [
            DBContact.self, DBConversation.self, DBMessage.self, DBMessageState.self,
            DBReceiver.self, DBSender.self, DBMessageMeta.self,
            DBAudioMessage.self, DBVoiceMessage.self,
            DBVideoMessage.self, DBPhotoMessage.self,
            DBMoneyMessage.self, DBFileMessage.self, DBContactMessage.self, DBLocationMessage.self,
            DBPhoto.self, DBSystemActionSupportManagerAssigned.self, DBSystemActionSupportStatusChanged.self,
            DBSystemActionType.self, DBCallMessage.self, DBMessageEntity.self, DBMessageEntityBold.self, DBMessageEntityItalic.self,
            DBMessageEntityPre.self, DBMessageEntityCode.self, DBMessageEntityURL.self, DBMessageEntityTextURL.self,
            DBMessageEntityEmail.self, DBMessageEntityPhone.self, DBMessageEntityUnderline.self,
            DBMessageEntityStrike.self, DBMessageEntityQuote.self, DBMessageEntityMention.self
        ]
        
        if let encryptionKey = UltraCoreSettings.delegate?.realmEncryptionKeyData() {
            config.encryptionKey = encryptionKey
        }

        do {
            let realm = try Realm(configuration: config)
            UltraCoreSettings.realmError = nil
            return realm
        } catch let error as NSError {
            UltraCoreSettings.realmError = error
            print("Error opening realm: \(error.localizedDescription)")
            return try? Realm() // если ошибка, то создаем объект Realm с настройками по умолчанию
        }
    }
    
    static var realmQueue = DispatchQueue(label: "UltracoreRealm")
}
