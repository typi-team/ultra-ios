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
    
    convenience init(from contact: Contact) {
        self.init()
        self.firstName = contact.firstname
        self.lastName = contact.lastname
        self.phone = contact.phone
        self.userID = contact.userID
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
        })
    }
}



extension DBContact : ContactDisplayable {
    var displaName: String { [firstName, lastName].joined(separator: " ") }
}
