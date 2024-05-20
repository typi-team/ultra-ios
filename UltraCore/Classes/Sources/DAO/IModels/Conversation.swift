//
//  Interface.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol Conversation: Any {
    
    var title: String { get }
    var peers: [ContactDisplayable] { get set }
    var timestamp: Date { get set }
    var unreadCount: Int { get set }
    var lastMessage: Message? { get set }
    var idintification: String { get set }
    var typingData: [UserTypingWithDate] { get set }
    var addContact: Bool { get set }
    var callAllowed: Bool { get set }
    var seqNumber: UInt64 { get set }
    var chatType: ConversationType { get set }
    var imagePath: String? { get set }
    var isAssistant: Bool { get set }
}

class ConversationImpl: Conversation {

    var title: String = ""
    var lastMessage: Message?
    var unreadCount: Int = 0
    var idintification: String
    var timestamp: Date = Date()
    var peers: [ContactDisplayable]
    var typingData: [UserTypingWithDate] = []
    var addContact: Bool
    var callAllowed: Bool
    var seqNumber: UInt64
    var chatType: ConversationType = .peerToPeer
    var imagePath: String?
    var isAssistant: Bool = false
    
    init(
        title: String?,
        contacts: [ContactDisplayable], 
        idintification: String,
        addContact: Bool,
        seqNumber: UInt64,
        callAllowed: Bool
    ) {
        self.peers = contacts
        self.title = title ?? (contacts.first?.displaName ?? "")
        self.lastMessage = nil
        self.idintification = idintification
        self.addContact = addContact
        self.seqNumber = seqNumber
        self.callAllowed = callAllowed
    }
    
    init(dbConversation: DBConversation) {
        self.title = dbConversation.title.isEmpty ? (dbConversation.contact.first?.toInterface().displaName ?? "") : dbConversation.title
        self.lastMessage = dbConversation.message?.toProto()
        
        self.peers = dbConversation.contact.map { $0.toInterface() }
        self.chatType = .init(rawValue: dbConversation.conversationType) ?? .peerToPeer
        self.idintification = dbConversation.idintification
        self.timestamp = dbConversation.lastSeen.date
        self.unreadCount = dbConversation.unreadMessageCount
        self.addContact = dbConversation.addContact
        self.seqNumber = UInt64(dbConversation.seqNumber)
        self.callAllowed = dbConversation.callAllowed
        self.isAssistant = dbConversation.isAssistant
        self.imagePath = dbConversation.imagePath.isEmpty ? nil : dbConversation.imagePath
    }
}

enum ConversationType: Int {
    case peerToPeer
    case simpleGroup
    case group
    case channel
    case support
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
        case .call(_):
            return MessageStrings.call.localized
        }
    }
}
