//
//  MessageInputBarConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

class MessageInputBarConfigImpl: MessageInputBarConfig {
    var blockedViewConfig: MessageInputBarBlockedConfig = MessageInputBarBlockedConfigImpl()
    
    var textConfig: TextViewConfig = LabelConfigImpl.init(darkColor: .white, defaultColor: .gray900, font: .defaultRegularSubHeadline,
                                                          tintColor: TwiceColorImpl(defaultColor: .green500, darkColor: .white))
    var dividerColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    var sendMessageViewTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var sendMoneyImage: TwiceImage = TwiceImageImpl(dark: .init(named: "sendMoney")!, default: .init(named: "sendMoney")!)
    var recordViewTint: TwiceColor = TwiceColorImpl(defaultColor: .gray400, darkColor: .white)
    var messageContainerBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    var messageTextViewBorderColor: TwiceColor = TwiceColorImpl(defaultColor: .from(hex: "#DBDEE3"), darkColor: .from(hex: "#DBDEE3"))
    var sendImage: TwiceImage = TwiceImageImpl(
        dark: .init(named: "conversation_send")!.withRenderingMode(.alwaysTemplate),
        default: .init(named: "conversation_send")!.withRenderingMode(.alwaysTemplate)
    )
    var plusImage: TwiceImage = TwiceImageImpl(
        dark: .init(named: "conversation_plus")!.withRenderingMode(.alwaysTemplate),
        default: .init(named: "conversation_plus")!.withRenderingMode(.alwaysTemplate)
    )
    var microphoneImage: TwiceImage = TwiceImageImpl(
        dark: .init(named: "message_input_micro")!.withRenderingMode(.alwaysTemplate),
        default: .init(named: "message_input_micro")!.withRenderingMode(.alwaysTemplate)
    )
}


class MessageInputBarBlockedConfigImpl: MessageInputBarBlockedConfig {
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    var dividerColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    var textConfig: TextViewConfig =  LabelConfigImpl.init(darkColor: .white,
                                                                     defaultColor: .white,
                                                                     font: .defaultRegularSubHeadline,
                                                                     tintColor: TwiceColorImpl(defaultColor: .green500,
                                                                                               darkColor: .white))
    
    var textBackgroundConfig: TwiceColor = TwiceColorImpl(defaultColor: .black, darkColor: .gray700)
    
}
