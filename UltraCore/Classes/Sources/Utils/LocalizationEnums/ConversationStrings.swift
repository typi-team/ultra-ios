//
//  ConversationStrings.swift
//  UltraCore
//
//  Created by Slam on 8/7/23.
//

import Foundation

enum ConversationStrings: String, StringLocalizable {
    
    
    case online
    case unknowNumber
    case moneyTransfer
    case insertMoney
    case send
    case insideTheBank
    case sendToBankCustomer
    case addAttachment
    case toMakeAPhoto
    case selectionFromLibrary
    case selectDocument
    case contact
    case location
    case prints
    case multivalue
    case block
    case unblock
    
    case transferAmount
    case writeOffTheCard
    case `continue`
    case money
    case thereAreNoMessagesInThisChat
    case insertText
    
    case today
    case yesterday
    
    case deleteFromMe
    case deleteForEveryone
    case areYouSure
    case pleaseNoteThatMessageDataWillBePermanentlyDeletedAndRecoveryWillNotBePossible
    
    case requestSent
    case givePermissionToRecordVoice
    case givePermissionToCamera
    case cameraPermissionRestricted
    case ifAMessageContainsThreatsInappropriateContentOrViolatesAnyPlatformOrCommunity
    case yourComplaintWillBeReviewedByModeratorsThankYou
    
    case disclaimer
    case disclaimerAgree
    case disclaimerClose
    
    var prefixOfTemplate: String { "conversation" }
    var localizableValue: String { rawValue }
}


enum ActionStrings: String, StringLocalizable {
    case decline
    
    var prefixOfTemplate: String { "conversation" }
    var localizableValue: String { rawValue }
}
    
enum EditActionStrings: String, StringLocalizable {
    case cancel
    case delete
    case report
    
    var prefixOfTemplate: String { "conversation" }
    var localizableValue: String { rawValue }
}
