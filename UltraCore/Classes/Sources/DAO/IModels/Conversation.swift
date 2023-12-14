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
    var lastMessage: Message? { get set }
    var idintification: String { get set }
    var typingData: [UserTypingWithDate] { get set }
}

class ConversationImpl: Conversation {

    var title: String = ""
    var lastMessage: Message?
    var unreadCount: Int = 0
    var idintification: String
    var timestamp: Date = Date()
    var peer: ContactDisplayable?
    var typingData: [UserTypingWithDate] = []
    
    init(contact: ContactDisplayable, idintification: String ) {
        self.peer = contact
        self.title = contact.displaName
        self.lastMessage = nil
        self.idintification = idintification
    }
    
    init(dbConversation: DBConversation) {
        self.title = dbConversation.contact?.toInterface().displaName ?? ""
        self.lastMessage = dbConversation.message?.toProto()
        
        self.peer = dbConversation.contact?.toInterface()
        self.idintification = dbConversation.idintification
        self.timestamp = dbConversation.lastSeen.date
        self.unreadCount = dbConversation.unreadMessageCount
    }
}

extension Message.OneOf_Content {
    var description: String {
        switch self {
        case .audio:
            return MessageStrings.audio.localized
        case .voice:
            return MessageStrings.voice.localized
        case .photo:
            return MessageStrings.photo.localized
        case .video:
            return MessageStrings.video.localized
        case .money:
            return MessageStrings.money.localized
        case .location:
            return MessageStrings.location.localized
        case .file:
            return MessageStrings.file.localized
        case .contact:
            return MessageStrings.contact.localized
        case .stock:
            return MessageStrings.moneyTransfer.localized
        case .coin:
            return MessageStrings.moneyTransfer.localized
        }
    }
}
