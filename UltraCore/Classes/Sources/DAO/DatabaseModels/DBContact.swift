//
//  DBContact.swift
//  _NIODataStructures
//
//  Created by Slam on 4/24/23.
//

import RealmSwift

class DBContact: Object {
    
    @objc dynamic var firstname = ""
    @objc dynamic var lastname = ""
    @objc dynamic var phone = ""
    @objc dynamic var userID = ""
    @objc dynamic var image: Data?
    @objc dynamic var imagePath: String?
    @objc dynamic var lastseen: Int64 = 0
    @objc dynamic var statusValue: Int = 0
    @objc dynamic var isBlocked: Bool = false
    
    convenience init(contact interface: ContactDisplayable) {
        self.init()
        self.phone = interface.phone
        self.userID = interface.userID
        self.lastname = interface.lastname
        self.firstname = interface.firstname
        self.isBlocked = interface.isBlocked
        self.imagePath = interface.imagePath
        self.image = interface.image?.pngData()
        self.lastseen = interface.status.lastSeen
        self.statusValue = interface.status.status.rawValue
    }
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    func toInterface() -> ContactDisplayable {
        ContactDisplayableImpl.init(dbContact: self)
    }
}
