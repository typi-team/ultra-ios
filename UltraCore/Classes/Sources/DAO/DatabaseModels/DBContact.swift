//
//  DBContact.swift
//  _NIODataStructures
//
//  Created by Slam on 4/24/23.
//

import RealmSwift

class DBContact: Object {
    
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var phone = ""
    @objc dynamic var userID = ""
    @objc dynamic var chatID = ""
    @objc dynamic var lastseen: Int64 = 0
    @objc dynamic var statusValue: Int = 0
    
    @objc dynamic var photo: DBPhoto?
    
    convenience init(from contact: Contact, user id: String = AppSettingsImpl.shared.appStore.userID()) {
        self.init()
        self.phone = contact.phone
        self.userID = contact.userID
        self.lastName = contact.lastname
        self.firstName = contact.firstname
        self.photo = .init(from: contact.photo)
        self.lastseen = contact.status.lastSeen
        self.statusValue = contact.status.status.rawValue
        self.chatID = "p\(id >= contact.userID ? id + contact.userID : contact.userID + id)"
        
    }
    
    convenience init(inner contact: IContact, user id: String = AppSettingsImpl.shared.appStore.userID()) {
        self.init()
        self.phone = contact.phone
        self.userID = contact.userID
        self.lastName = contact.lastname
        self.firstName = contact.firstname
        self.photo = nil
        self.lastseen = 0
        self.statusValue = 0
        self.chatID = "p\(id >= contact.userID ? id + contact.userID : contact.userID + id)"
        
    }
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    func toProto() -> Contact {
        return .with({
            $0.firstname = firstName
            $0.lastname = lastName
            $0.phone = phone
            $0.userID = userID
            $0.photo = photo?.toProto() ?? Photo()
            $0.status = .with({ stat in
                stat.userID = userID
                stat.status = statusEnum
                stat.lastSeen = lastseen
            })
        })
    }
}
