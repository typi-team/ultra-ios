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
    
    
    override static func primaryKey() -> String? {
        return "phone"
    }
}

extension DBContact : ContactDisplayable {
    var displaName: String { [firstName, lastName].joined(separator: " ") }
}
