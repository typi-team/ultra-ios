//
//  MessageStrings.swift
//  UltraCore
//
//  Created by Slam on 8/7/23.
//

import Foundation

enum MessageStrings: String, StringLocalizable {
    
    case audio
    case voice
    case photo
    case video
    case money
    case location
    case file
    case contact
    case moneyTransfer
    case uploadingInProgress
    case fileWithoutSmile
    
    case reply
    case copy
    case report
    case delete
    case select
    
    case spam
    case personalData
    case fraud
    case impositionOfServices
    case insult
    case other
    case additionalInformationInComments
    case comment
    
    case sorryButYouHaveBlockedThisChatIfYouHaveAnyQuestionsOrNeedAssistancePleaseContactOurSupportService

    var prefixOfTemplate: String { "message" }
    var localizableValue: String { rawValue }
}
