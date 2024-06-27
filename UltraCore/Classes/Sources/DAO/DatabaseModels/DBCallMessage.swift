//
//  DBCallMessage.swift
//  UltraCore
//
//  Created by Typi on 20.06.2024.
//

import Foundation
import RealmSwift

class DBCallMessage: Object {
    @objc dynamic var startTime: Int64 = 0
    @objc dynamic var endTime: Int64 = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var room: String = ""
    
    convenience init(callMessage: CallMessage) {
        self.init()
        self.startTime = callMessage.startTime
        self.endTime = callMessage.endTime
        self.status = callMessage.status.rawValue
        self.room = callMessage.room
    }
    
    override static func primaryKey() -> String? {
        return "room"
    }
    
    func toProto() -> CallMessage {
        return .with { message in
            message.room = room
            message.startTime = startTime
            message.endTime = endTime
            message.status = .init(rawValue: status) ?? .callStatusCreated
        }
    }
}
