//
//  DBConversation.swift
//  UltraCore
//
//  Created by Slam on 5/2/23.
//

import RealmSwift

class DBConversation: Object {
    
    @objc dynamic var contact: DBContact?
    @objc dynamic var lastSeen: Int64 = 0
    @objc dynamic var message: DBMessage?
    @objc dynamic var idintification: String = ""
    @objc dynamic var unreadMessageCount: Int = 0
    @objc dynamic var addContact: Bool = false
    @objc dynamic var seqNumber: Int = 0
    
    var typingData: [UserTypingWithDate] = []
    
    override static func primaryKey() -> String? {
        return "idintification"
    }
    
    convenience init(conversation: Conversation) {
        self.init()
        self.message = nil
        if let contact = conversation.peer {
            self.contact = DBContact.init(contact: contact)
        } else {
            fatalError("handle this case")
        }
        self.lastSeen = conversation.timestamp.nanosec
        self.idintification = conversation.idintification
        self.unreadMessageCount = conversation.unreadCount
        self.addContact = conversation.addContact
        self.seqNumber = Int(conversation.seqNumber)
    }
    
    convenience init(message: Message, realm: Realm = .myRealm(), user id: String?) {
        self.init()
        
        self.lastSeen = message.meta.created
        self.message = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) ?? DBMessage.init(from: message, realm: realm, user: id)
        self.idintification = message.receiver.chatID
        self.contact = realm.object(ofType: DBContact.self, forPrimaryKey: message.sender.userID == id ? message.receiver.userID : message.sender.userID)
        self.seqNumber = Int(message.seqNumber)
        
    }
    
    func toConversation() -> Conversation {
        return ConversationImpl.init(dbConversation: self)
    }
}
