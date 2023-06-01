//
//  DBMessage.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import RealmSwift

class DBMessage: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var state: DBMessageState? = DBMessageState()
    @objc dynamic var chatType: Int = ChatTypeEnum.peerToPeer.rawValue
    @objc dynamic var seqNumber: Int64 = 0
    @objc dynamic var type: Int = MessageTypeEnum.text.rawValue
    @objc dynamic var receiver: DBReceiver? = DBReceiver()
    @objc dynamic var sender: DBSender? = DBSender()
    @objc dynamic var meta: DBMessageMeta? = DBMessageMeta.init()
    @objc dynamic var text: String = ""
    @objc dynamic var audioMessage: DBAudioMessage?
    @objc dynamic var voiceMessage: DBVoiceMessage?
    @objc dynamic var photoMessage: DBPhotoMessage?
    @objc dynamic var videoMessage: DBVideoMessage?
    @objc dynamic var isIncome: Bool = false
    
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(from message: Message, realm: Realm = .myRealm(), user id: String?) {
        self.init()
        self.id = message.id
        self.state = DBMessageState.init(messageState: message.state)
        self.chatType = message.chatType.rawValue
        self.seqNumber = Int64(message.seqNumber)
        self.type = message.type.rawValue
        self.receiver = realm.object(ofType: DBReceiver.self, forPrimaryKey: message.receiver.chatID) ?? DBReceiver.init(message.receiver)
        self.sender = realm.object(ofType: DBSender.self, forPrimaryKey: message.sender.userID) ?? DBSender.init(from: message.sender)
        self.meta = DBMessageMeta.init(proto: message.meta)
        self.text = message.text
        switch message.content {
        case .audio(let audioMessage):
            self.audioMessage = .init(fromProto: audioMessage)
        case .voice(let voiceMessage):
            self.voiceMessage = .init(fromProto: voiceMessage)
        case .photo(let photoMessage):
            self.photoMessage = .init(fromProto: photoMessage)
        case .video(let videoMessage):
            self.videoMessage = .init(videoMessage: videoMessage)
        default:
            break
        }
        
        if let id = id {
            self.isIncome = message.receiver.userID == id
        }
    }
    
    func toProto() -> Message {
        var message = Message()
        message.id = id
        message.state = state!.toProto()
        message.chatType = ChatTypeEnum(rawValue: chatType) ?? ChatTypeEnum.peerToPeer
        message.seqNumber = UInt64(seqNumber)
        message.type = MessageTypeEnum.init(rawValue: self.type) ?? MessageTypeEnum.text
        message.receiver = receiver!.toProto()
        message.sender = sender!.toProto()
        message.meta = meta!.toProto()
        message.text = self.text
        if let audioMessage = audioMessage {
            message.content = .audio(audioMessage.toProto())
        } else if let voiceMessage = voiceMessage {
            message.content = .voice(voiceMessage.toProto())
        } else if let photoMessage = photoMessage {
            message.content = .photo(photoMessage.toProto())
        } else if let videoMessage = videoMessage {
            message.content = .video(videoMessage.toProto())
        }
        
        return message
    }
}

class DBMessageState: Object {
    @Persisted var read: Bool = false
    @Persisted var delivered: Bool = false
    @Persisted var edited: Int64 = 0

    convenience init(messageState: MessageState) {
        self.init()
        self.read = messageState.read
        self.delivered = messageState.delivered
        self.edited = messageState.edited
    }
    
    func toProto() ->  MessageState {
        return .with({
            $0.read = self.read
            $0.edited = self.edited
            $0.delivered = self.delivered
        })
    }
}

class DBReceiver: Object {
    @Persisted var userID: String = ""
    @Persisted var chatID: String = ""
    
    override static func primaryKey() -> String? {
        return "chatID"
    }
    
    convenience init(_ receiver: Receiver) {
        self.init()
        self.userID = receiver.userID
        self.chatID = receiver.chatID
    }
    
    func toProto() -> Receiver {
        return  Receiver.with({
            $0.chatID = self.chatID
            $0.userID = self.userID
        })
    }
}

class DBSender: Object {
    @Persisted var userID: String = ""
    @Persisted var deviceID: String = ""
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    convenience init(from sender: Sender) {
        self.init()
        userID = sender.userID
        deviceID = sender.deviceID
    }
    
    func toProto() ->  Sender {
        return Sender.with {
            $0.userID = userID
            $0.deviceID = deviceID
        }
    }
}


class DBMessageMeta: Object {
    @objc dynamic var created: Int64 = 0
    

    convenience init(proto: MessageMeta) {
        self.init()
        created = proto.created
    }

    func toProto() -> MessageMeta {
        return MessageMeta.with { $0.created = self.created}
    }
}

class DBAudioMessage: Object {
    @objc dynamic var fileID: String = ""
    @objc dynamic var duration: Int64 = 0
    @objc dynamic var fileSize: Int64 = 0
    @objc dynamic var mimeType: String = ""
    @objc dynamic var fileName: String = ""
    
    convenience init(fromProto proto: AudioMessage) {
        self.init()
        self.fileID = proto.fileID
        self.duration = proto.duration
        self.fileSize = proto.fileSize
        self.mimeType = proto.mimeType
        self.fileName = proto.fileName
    }
    
    override static func primaryKey() -> String? {
        return "fileID"
    }
    
    func toProto() -> AudioMessage {
        var proto = AudioMessage()
        proto.fileID = self.fileID
        proto.duration = self.duration
        proto.fileSize = self.fileSize
        proto.mimeType = self.mimeType
        proto.fileName = self.fileName
        return proto
    }
}

class DBVoiceMessage: Object {
    @objc dynamic var fileID: String = ""
    @objc dynamic var duration: Int64 = 0
    @objc dynamic var fileSize: Int64 = 0
    @objc dynamic var mimeType: String = ""
    @objc dynamic var fileName: String = ""
    
    override static func primaryKey() -> String? {
        return "fileID"
    }
    
    convenience init(fromProto proto: VoiceMessage) {
        self.init()
        self.fileID = proto.fileID
        self.duration = proto.duration
        self.fileSize = proto.fileSize
        self.mimeType = proto.mimeType
        self.fileName = proto.fileName
    }
    
    func toProto() -> VoiceMessage {
        var proto = VoiceMessage()
        proto.fileID = self.fileID
        proto.duration = self.duration
        proto.fileSize = self.fileSize
        proto.mimeType = self.mimeType
        proto.fileName = self.fileName
        return proto
    }
}

class DBPhotoMessage: Object {
    @objc dynamic var fileID: String = ""
    @objc dynamic var fileSize: Int64 = 0
    @objc dynamic var mimeType: String = ""
    @objc dynamic var fileName: String = ""
    @objc dynamic var width: Int32 = 0
    @objc dynamic var height: Int32 = 0
    @objc dynamic var preview: Data = Data()
    
    override static func primaryKey() -> String? {
        return "fileID"
    }
    
    convenience init(fromProto proto: PhotoMessage) {
        self.init()
        self.fileID = proto.fileID
        self.fileSize = proto.fileSize
        self.mimeType = proto.mimeType
        self.fileName = proto.fileName
        self.width = proto.width
        self.height = proto.height
        self.preview = proto.preview
    }
    
    func toProto() -> PhotoMessage {
        var proto = PhotoMessage()
        proto.fileID = self.fileID
        proto.fileSize = self.fileSize
        proto.mimeType = self.mimeType
        proto.fileName = self.fileName
        proto.width = self.width
        proto.height = self.height
        proto.preview = self.preview
        return proto
    }
}

class DBVideoMessage: Object {
    @objc dynamic var fileID: String = ""
    @objc dynamic var duration: Int64 = 0
    @objc dynamic var fileSize: Int64 = 0
    @objc dynamic var mimeType: String = ""
    @objc dynamic var fileName: String = ""
    @objc dynamic var width: Int32 = 0
    @objc dynamic var height: Int32 = 0
    @objc dynamic var preview: Data = Data()
    
    override static func primaryKey() -> String? {
        return "fileID"
    }

    convenience init(videoMessage: VideoMessage) {
        self.init()
        self.fileID = videoMessage.fileID
        self.duration = videoMessage.duration
        self.fileSize = videoMessage.fileSize
        self.mimeType = videoMessage.mimeType
        self.fileName = videoMessage.fileName
        self.width = videoMessage.width
        self.height = videoMessage.height
        self.preview = videoMessage.thumbPreview
    }

    func toProto() -> VideoMessage {
        var videoMessage = VideoMessage()
        videoMessage.fileID = self.fileID
        videoMessage.duration = self.duration
        videoMessage.fileSize = self.fileSize
        videoMessage.mimeType = self.mimeType
        videoMessage.fileName = self.fileName
        videoMessage.width = self.width
        videoMessage.height = self.height
        videoMessage.thumbPreview = self.preview
        return videoMessage
    }
}

