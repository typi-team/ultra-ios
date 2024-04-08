//
//  MessageInputBarConfig.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol MessageInputBarConfig {
    var dividerColor: TwiceColor { get set }
    var background: TwiceColor { get set }
    var textConfig: TextViewConfig { get set }
    var sendMessageViewTint: TwiceColor { get set }
    var sendMoneyImage: TwiceImage { get set }
    var recordViewTint: TwiceColor { get set }
    var messageContainerBackground: TwiceColor { get set }
    
    var sendImage: TwiceImage { get set }
    var plusImage: TwiceImage { get set }
    var microphoneImage: TwiceImage { get set }
    
    var blockedViewConfig: MessageInputBarBlockedConfig { get set }
}

public protocol MessageInputBarBlockedConfig {
    var background: TwiceColor { get set }
    var textConfig: TextViewConfig { get set }
    var dividerColor: TwiceColor { get set }
    var textBackgroundConfig: TwiceColor { get set }
}
