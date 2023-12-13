//
//  ContactDisplayable.swift
//  UltraCore
//
//  Created by Slam on 5/19/23.
//

import Foundation


protocol ContactDisplayable: Any {
    var phone: String { get }
    var userID: String { get }
    var isBlocked: Bool { get }
    var displaName: String { get }
    var status: UserStatus { get }
    var image: UIImage? { get }
    var imagePath: String? { get }
    
    var firstname: String { get }
    var lastname: String { get }
}

extension ContactDisplayable {
    var displaName: String {
        if let contact = UltraCoreSettings.delegate?.info(from: self.phone) {
            return [contact.firstname, contact.lastname].joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return [" ", firstname, " ", lastname, " "].joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

class ContactDisplayableImpl: ContactDisplayable {
    
    var phone: String
    var userID: String
    var isBlocked: Bool
    var firstname: String
    var lastname: String
    var status: UserStatus
    var image: UIImage?
    var imagePath: String?
    
    
    init(dbContact: DBContact) {
        phone = dbContact.phone
        userID = dbContact.userID
        isBlocked = dbContact.isBlocked
        firstname = dbContact.firstname
        lastname = dbContact.lastname
        imagePath = dbContact.imagePath
        image = UIImage(data: dbContact.image ?? Data())
        
        status = UserStatus.with({
            $0.lastSeen = dbContact.lastseen
            $0.userID = dbContact.userID
            $0.status = .init(rawValue: dbContact.statusValue) ?? .unknown
        })
    }
    
    init(contact: Contact) {
        phone = contact.phone
        userID = contact.userID
        isBlocked = contact.isBlocked
        firstname = contact.firstname
        lastname = contact.lastname
        status = contact.status
        image = UIImage(data: contact.photo.preview)
        imagePath = nil
    }
    
}
