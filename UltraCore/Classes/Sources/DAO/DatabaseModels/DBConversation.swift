//
//  DBConversation.swift
//  UltraCore
//
//  Created by Slam on 5/2/23.
//

import RealmSwift

class DBConversation: Object {
    
    @objc dynamic var peer: DBContact?
    @objc dynamic var lastSeen: Int64 = 0
    @objc dynamic var message: DBMessage?
    @objc dynamic var idintification: String = ""
    @objc dynamic var unreadMessageCount: Int = 0
    
    override static func primaryKey() -> String? {
        return "idintification"
    }
    
    convenience init(conversation: Conversation) {
        self.init()
        self.message = nil
        self.peer = conversation.peer
        self.lastSeen = conversation.timestamp.nanosec
        self.idintification = conversation.idintification
        self.unreadMessageCount = conversation.unreadCount
    }
    
    convenience init(message: Message, realm: Realm = .myRealm()) {
        self.init()
        
        self.lastSeen = message.meta.created
        self.message = DBMessage.init(from: message, realm: realm)
        self.idintification = message.receiver.chatID
        
    }
}

extension DBConversation: Conversation {
    
    var title: String {
        return self.peer?.displaName ?? ""
    }
    
    var timestamp: Date {
        get {
            return self.lastSeen.date
        }
        set {
            self.lastSeen = newValue.nanosec
        }
    }
    
    var lastMessage: String? {
        get {
            return self.message?.textMessage?.content
        }
        set {
            self.message?.textMessage?.content = newValue ?? ""
        }
    }
    
    var unreadCount: Int {
        get {
            return 0
        }
        set {
            
        }
    }
    

}
