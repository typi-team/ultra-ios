//
//  DBMessageEntity.swift
//  UltraCore
//
//  Created by Typi on 13.08.2024.
//

import RealmSwift

class DBMessageEntity: Object {
    @objc dynamic var bold: DBMessageEntityBold?
    @objc dynamic var italic: DBMessageEntityItalic?
    @objc dynamic var pre: DBMessageEntityPre?
    @objc dynamic var code: DBMessageEntityCode?
    @objc dynamic var URL: DBMessageEntityURL?
    @objc dynamic var textURL: DBMessageEntityTextURL?
    @objc dynamic var email: DBMessageEntityEmail?
    @objc dynamic var phone: DBMessageEntityPhone?
    @objc dynamic var underline: DBMessageEntityUnderline?
    @objc dynamic var strike: DBMessageEntityStrike?
    @objc dynamic var quote: DBMessageEntityQuote?
    @objc dynamic var mention: DBMessageEntityMention?
}

class DBMessageEntityBold: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityBold) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityBold {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityItalic: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityItalic) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityItalic {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityPre: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    @objc dynamic var language: String = ""
    
    convenience init(proto: MessageEntityPre) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
        self.language = proto.language
    }
    
    func toProto() -> MessageEntityPre {
        return .with { obj in
            obj.length = length
            obj.offset = offset
            obj.language = language
        }
    }
}

class DBMessageEntityCode: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityCode) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityCode {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityURL: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityUrl) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityUrl {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityTextURL: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    @objc dynamic var URL: String = ""
    
    convenience init(proto: MessageEntityTextUrl) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
        self.URL = proto.url
    }
    
    func toProto() -> MessageEntityTextUrl {
        return .with { obj in
            obj.length = length
            obj.offset = offset
            obj.url = URL
        }
    }
}

class DBMessageEntityEmail: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityEmail) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityEmail {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityPhone: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityPhone) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityPhone {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityUnderline: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityUnderline) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityUnderline {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityStrike: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityStrike) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityStrike {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityQuote: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    
    convenience init(proto: MessageEntityQuote) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
    }
    
    func toProto() -> MessageEntityQuote {
        return .with { obj in
            obj.length = length
            obj.offset = offset
        }
    }
}

class DBMessageEntityMention: Object {
    @objc dynamic var offset: Int32 = 0
    @objc dynamic var length: Int32 = 0
    @objc dynamic var userID: String = ""
    
    convenience init(proto: MessageEntityMention) {
        self.init()
        self.offset = proto.offset
        self.length = proto.length
        self.userID = proto.userID
    }
    
    func toProto() -> MessageEntityMention {
        return .with { obj in
            obj.length = length
            obj.offset = offset
            obj.userID = userID
        }
    }
}
