//
//  MessageSendRequest+Extension.swift
//  UltraCore
//
//  Created by Typi on 18.04.2024.
//

import Foundation

extension MessageSendRequest {
    mutating func updatePeer(with conversation: Conversation) {
        if conversation.chatType == .peerToPeer {
            peer.user = .with({ peerUser in
                peerUser.userID = conversation.peers.first?.userID ?? ""
            })
        } else {
            peer.chat = .with({ peerChat in
                peerChat.chatID = conversation.idintification
            })
        }
    }
}
