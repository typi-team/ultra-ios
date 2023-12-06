//
//  Interface.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol Conversation: Any {
    
    var title: String { get }
    var peer: ContactDisplayable? { get set }
    var timestamp: Date { get set }
    var unreadCount: Int { get set }
    var lastMessage: String? { get set }
    var idintification: String { get set }
    var typingData: [UserTypingWithDate] { get set }
    var isLastMessageIncome: Bool? { get }
    var read: Bool? { get }
}

class ConversationImpl: Conversation {

    var title: String = ""
    var lastMessage: String?
    var unreadCount: Int = 0
    var idintification: String
    var timestamp: Date = Date()
    var peer: ContactDisplayable?
    var typingData: [UserTypingWithDate] = []
    var isLastMessageIncome: Bool?
    var read: Bool?
    
    init(contact: ContactDisplayable, idintification: String ) {
        self.peer = contact
        self.title = contact.displaName
        self.lastMessage = contact.phone
        self.idintification = idintification
    }
}
