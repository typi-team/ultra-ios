//
//  ConversationScreenStyleConfig.swift
//  UltraCore
//
//  Created by Typi on 10.04.2024.
//

import Foundation

public protocol ConversationScreenStyleConfig {
    var startConversationImage: TwiceImage { get set }
    var conversationOptionsImage: TwiceImage { get set }
    var conversationVideoCallImage: TwiceImage { get set }
    var conversationVoiceCallImage: TwiceImage { get set }
    var loaderTintColor: TwiceColor { get set }
}
