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
    
    var typingData: Set<UserTypingWithDate> = .init()
    
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
    
    convenience init(message: Message, realm: Realm = .myRealm(), user id: String?) {
        self.init()
        
        self.lastSeen = message.meta.created
        self.message = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) ?? DBMessage.init(from: message, realm: realm, user: id)
        self.idintification = message.receiver.chatID
        peer = realm.object(ofType: DBContact.self, forPrimaryKey: message.sender.userID == id ? message.receiver.userID : message.sender.userID)
        
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
            return self.message?.text
        }
        set {
            self.message?.text = newValue ?? ""
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
