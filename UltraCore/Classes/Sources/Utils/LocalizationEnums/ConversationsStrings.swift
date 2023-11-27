//
//  ConversationsStrings.swift
//  _NIODataStructures
//
//  Created by Slam on 8/7/23.
//

import Foundation

enum ConversationsStrings:  String {
    case chats
    case emptyMessages
    case startCommunicatingWithYourContactsNow
    case start

}

extension ConversationsStrings: StringLocalizable {
    var prefixOfTemplate: String { "conversations" }
    var localizableValue: String { rawValue }
}
