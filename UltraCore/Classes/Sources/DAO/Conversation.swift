//
//  Interface.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol Conversation: Any {
    var title: String { get set }
    var lastSeen: Date { get set }
    var unreadCount: Int { get set }
    var description: String { get set }
}


class DummyConversationImpl: Conversation {
    var title: String = "FF Chat"
    
    var lastSeen: Date = Date()
    
    var unreadCount: Int = 0
    
    var description: String = "Freedom chat"
}
