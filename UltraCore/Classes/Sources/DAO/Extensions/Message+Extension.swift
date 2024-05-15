//
//  Message+Extension.swift
//  UltraCore
//
//  Created by Typi on 26.04.2024.
//

import Foundation

extension Message {
    var shouldBeSaved: Bool {
        guard let systemAction = systemAction else {
            return true
        }
        
        switch systemAction {
        case .chatCreated:
            return false
        case .titleEdited:
            return false
        case .membersAdded:
            return false
        case .memberDeleted:
            return false
        case .photoEdited:
            return false
        case .photoDeleted:
            return false
        case .supportManagerAssigned:
            return true
        case .supportStatusChanged(let systemActionSupportStatusChanged):
            switch systemActionSupportStatusChanged.status {
            case .supportChatStatusClosed:
                return true
            case .supportChatStatusPostponed:
                return true
            case .supportChatStatusOpen:
                return true
            case .supportChatStatusAny:
                return false
            case .supportChatStatusCreated:
                return false
            case .UNRECOGNIZED:
                return false
            }
        case .customTextSended:
            return true
        }
    }
    
    // Returns: Support message
    var supportMessage: String {
        guard let systemAction = systemAction else {
            return ""
        }
        
        switch systemAction {
        case .chatCreated:
            return ""
        case .titleEdited:
            return ""
        case .membersAdded:
            return ""
        case .memberDeleted:
            return ""
        case .photoEdited:
            return ""
        case .photoDeleted:
            return ""
        case .supportManagerAssigned(let supportManagerAssigned):
            return String.init(
                format: ConversationStrings.supportChatManagerAssigned.localized, supportManagerAssigned.userID
            )
        case .supportStatusChanged(let systemActionSupportStatusChanged):
            switch systemActionSupportStatusChanged.status {
            case .supportChatStatusClosed:
                return ConversationStrings.supportChatClosed.localized
            case .supportChatStatusPostponed:
                return ConversationStrings.supportChatPostponed.localized
            case .supportChatStatusOpen:
                return ConversationStrings.supportChatOpened.localized
            case .supportChatStatusAny:
                return ""
            case .supportChatStatusCreated:
                return ""
            case .UNRECOGNIZED:
                return ""
            }
        case .customTextSended:
            return text
        }
    }
}
