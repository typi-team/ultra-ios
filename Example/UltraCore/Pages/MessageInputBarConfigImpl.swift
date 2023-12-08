//
//  MessageInputBarConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

class MessageInputBarConfigImpl: MessageInputBarConfig {
    var textConfig: TextViewConfig = LabelConfigImpl.init(darkColor: .white, defaultColor: .gray900, font: .defaultRegularSubHeadline,
                                                          tintColor: TwiceColorImpl(defaultColor: .green500, darkColor: .white))
    var dividerColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    var sendMessageViewTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var sendMoneyViewTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var recordViewTint: TwiceColor = TwiceColorImpl(defaultColor: .gray400, darkColor: .white)
    var messageContainerBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
}
