//
//  ContactsStrings.swift
//  UltraCore
//
//  Created by Slam on 8/7/23.
//

import Foundation

enum ContactsStrings: String, StringLocalizable {
    case newChat
    case was
    case justNow
    case backward
    case yesterday
    
    case yourContactListIsEmpty
    case unfortunately
    case noAccessToContacts
    case clickToShareContacts
    
    
    var prefixOfTemplate: String { "contacts" }
    var localizableValue: String { rawValue }
}
