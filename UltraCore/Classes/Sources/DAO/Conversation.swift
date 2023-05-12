//
//  Interface.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol Conversation: Any {
    
    var title: String { get }
    var peer: DBContact? { get }
    var timestamp: Date { get set }
    var unreadCount: Int { get set }
    var lastMessage: String? { get set }
    var idintification: String { get set }
}

class ConversationImpl: Conversation {
    var peer: DBContact?
    var title: String = ""
    var lastMessage: String?
    var unreadCount: Int = 0
    var idintification: String
    var timestamp: Date = Date()
    
    init(contact: DBContact ) {
        self.peer = contact
        self.idintification = contact.chatID
        self.title = contact.displaName
        self.lastMessage = contact.phone
    }
}
