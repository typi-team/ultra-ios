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
    var sendMoneyViewTint: TwiceColor { get set }
    var recordViewTint: TwiceColor { get set }
    var messageContainerBackground: TwiceColor { get set }
    
    var blockedViewConfig: MessageInputBarBlockedConfig { get set }
}

public protocol MessageInputBarBlockedConfig {
    var background: TwiceColor { get set }
    var textConfig: TextViewConfig { get set }
    var textBackgroundConfig: TwiceColor { get set }
}
