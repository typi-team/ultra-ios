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
