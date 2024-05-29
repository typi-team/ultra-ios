//
//  DBSystemMesageModels.swift
//  UltraCore
//
//  Created by Typi on 24.04.2024.
//

import Foundation
import RealmSwift

enum SystemActionType: Int {
    case chatCreated
    case titleEdited
    case membersAdded
    case memberDeleted
    case photoEdited
    case photoDeleted
    case supportManagerAssigned
    case supportStatusChanged
    case customTextSended
}

class DBSystemActionType: Object {
    @objc dynamic var type: Int = 0
    
    convenience init(systemAction: Message.OneOf_SystemAction) {
        self.init()
        switch systemAction {
        case .chatCreated(let systemActionChatCreate):
            type = 0
        case .titleEdited(let systemActionChatEditTitle):
            type = 1
        case .membersAdded(let systemActionChatAddMember):
            type = 2
        case .memberDeleted(let systemActionChatDeleteMember):
            type = 3
        case .photoEdited(let systemActionChatEditPhoto):
            type = 4
        case .photoDeleted(let systemActionChatDeletePhoto):
            type = 5
        case .supportManagerAssigned(let systemActionSupportManagerAssigned):
            type = 6
        case .supportStatusChanged(let systemActionSupportStatusChanged):
            type = 7
        case .customTextSended(_):
            type = 8
        }
    }
    
    func getActionType() -> SystemActionType? {
        return SystemActionType(rawValue: type)
    }
}

class DBSystemActionSupportManagerAssigned: Object {
    @objc dynamic var userID: String = ""
    
    convenience init(action: SystemActionSupportManagerAssigned) {
        self.init()
        self.userID = action.userID
    }
}

class DBSystemActionSupportStatusChanged: Object {
    @objc dynamic var status: Int = 0
    
    convenience init(action: SystemActionSupportStatusChanged) {
        self.init()
        self.status = action.status.rawValue
    }
}
