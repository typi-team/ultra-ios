//
//  Receiver+Extension.swift
//  UltraCore
//
//  Created by Typi on 18.04.2024.
//

import Foundation

extension Receiver {
    static func from(conversation: Conversation) -> Receiver {
        return Receiver.with { receiver in
            receiver.chatID = conversation.idintification
            receiver.userID = conversation.peers.first?.userID ?? ""
        }
    }
}

