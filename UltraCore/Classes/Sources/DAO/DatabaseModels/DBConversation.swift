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
    
    var unreadCount: Int = 0
    var typingData: [UserTypingWithDate] = []
    
    override static func primaryKey() -> String? {
        return "idintification"
    }
    
    convenience init(conversation: Conversation, user id: String?) {
        self.init()
        self.message = nil
        if let contact = conversation.peer as? DBContact {
            self.contact = contact
        } else if let contact = conversation.peer as? Contact, let id = id {
            self.contact = DBContact.init(from: contact, user: id)
        } else {
            fatalError("handle this case")
        }
        self.lastSeen = conversation.timestamp.nanosec
        self.idintification = conversation.idintification
        self.unreadMessageCount = conversation.unreadCount
    }
    
    convenience init(message: Message, realm: Realm = .myRealm(), user id: String?) {
        self.init()
        
        self.lastSeen = message.meta.created
        self.message = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) ?? DBMessage.init(from: message, realm: realm, user: id)
        self.idintification = message.receiver.chatID
        self.contact = realm.object(ofType: DBContact.self, forPrimaryKey: message.sender.userID == id ? message.receiver.userID : message.sender.userID)
        
    }
}

extension DBConversation: Conversation {
    var peer: ContactDisplayable? {
        get { self.contact }
        set {
            
            if let contact = newValue as? DBContact {
                self.contact = contact
            } else if let contact = newValue as? Contact {
                self.contact = DBContact.init(from: contact)
            } else {
                fatalError("handle this case")
            }
        }
    }
    var title: String {
        return self.contact?.displaName ?? ""
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
            if let content = message?.toProto().content {
                switch content {
                case .audio(_):
                    return "🔉 Аудио"
                case .voice(_):
                    return "🎤 Голосовое сообщение"
                case .photo(_):
                    return "📷 Фото"
                case .video(_):
                    return "🎥 Видео"
                case .money(_):
                    return "💵 Денежный перевод"
                case .location(_):
                    return "📍Локация"
                case .file(_):
                    return "📂 Файл"
                case .contact(_):
                    return "📇 Контакт"
                }
            } else {
                return self.message?.text
            }
        }
        set {
            self.message?.text = newValue ?? ""
        }
    }
}
