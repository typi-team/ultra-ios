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
    var typingData: Set<UserTypingWithDate> { get set }
}

class ConversationImpl: Conversation {

    var peer: DBContact?
    var title: String = ""
    var lastMessage: String?
    var unreadCount: Int = 0
    var idintification: String
    var timestamp: Date = Date()
    var typingData: Set<UserTypingWithDate> = Set()
    
    init(contact: DBContact ) {
        self.peer = contact
        self.idintification = contact.chatID
        self.title = contact.displaName
        self.lastMessage = contact.phone
    }
}
