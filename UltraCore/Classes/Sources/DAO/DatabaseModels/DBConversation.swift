//
//  DBConversation.swift
//  UltraCore
//
//  Created by Slam on 5/2/23.
//

import RealmSwift

class DBConversation: Object {
    
    var contact = List<DBContact>()
    @objc dynamic var lastSeen: Int64 = 0
    @objc dynamic var message: DBMessage?
    @objc dynamic var idintification: String = ""
    @objc dynamic var unreadMessageCount: Int = 0
    @objc dynamic var addContact: Bool = false
    @objc dynamic var callAllowed: Bool = true
    @objc dynamic var seqNumber: Int = 0
    @objc dynamic var conversationType: Int = 0
    @objc dynamic var imagePath: String = ""
    @objc dynamic var title: String = ""
    
    var typingData: [UserTypingWithDate] = []
    
    override static func primaryKey() -> String? {
        return "idintification"
    }
    
    convenience init(conversation: Conversation, contacts: [DBContact]) {
        self.init()
        self.message = nil
        contacts
            .forEach(contact.append(_:))
        self.lastSeen = conversation.timestamp.nanosec
        self.idintification = conversation.idintification
        self.unreadMessageCount = conversation.unreadCount
        self.addContact = conversation.addContact
        self.callAllowed = conversation.callAllowed
        self.seqNumber = Int(conversation.seqNumber)
        self.conversationType = conversation.chatType.rawValue
        self.imagePath = conversation.imagePath ?? ""
    }
    
    convenience init(message: Message, realm: Realm = .myRealm(), user id: String?, addContact: Bool, callAllowed: Bool) {
        self.init()
        
        self.lastSeen = message.meta.created
        self.message = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) ?? DBMessage.init(from: message, realm: realm, user: id)
        self.idintification = message.receiver.chatID
        if let dbContact = realm.object(ofType: DBContact.self, forPrimaryKey: message.sender.userID == id ? message.receiver.userID : message.sender.userID),
            !contact.contains(where: { $0.userID == dbContact.userID })
        {
            self.contact.append(dbContact)
        }
        self.addContact = addContact
        self.callAllowed = callAllowed
        self.seqNumber = Int(message.seqNumber)
        
    }
    
    func toConversation() -> Conversation {
        return ConversationImpl.init(dbConversation: self)
    }
}
