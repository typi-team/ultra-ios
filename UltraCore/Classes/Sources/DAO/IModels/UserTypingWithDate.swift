//
//  UserTypingWithDate.swift
//  UltraCore
//
//  Created by Slam on 12/14/23.
//

import Foundation

struct UserTypingWithDate: Hashable {
    var chatId: String
    var userId: String
    var createdAt: Date
    
    init(chatId: String, userId: String, createdAt: Date = Date()) {
        self.chatId = chatId
        self.userId = userId
        self.createdAt = createdAt
    }
    
    
    init(user typing: UserTyping) {
        self.createdAt = Date()
        self.chatId = typing.chatID
        self.userId = typing.userID
    }
    
    var isTyping: Bool {
        return Date().timeIntervalSince(createdAt) < kTypingMinInterval
    }
    
    static func == (lhs: UserTypingWithDate, rhs: UserTypingWithDate) -> Bool {
        return lhs.chatId == rhs.chatId
    }
}
