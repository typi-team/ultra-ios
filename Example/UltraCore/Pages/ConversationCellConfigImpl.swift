//
//  ConversationCellConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

class ConversationCellConfigImpl: ConversationCellConfig {
    var loadingImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_loading"),
        default: .init(named: "conversation_status_loading")
    )
    var sentImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_sent"),
        default: .init(named: "conversation_status_sent")
    )
    var deliveredImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_delivered"),
        default: .init(named: "conversation_status_delivered")
    )
    var readImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_read"),
        default: .init(named: "conversation_status_read")
    )
    
    var unreadBackgroundColor: UltraCore.TwiceColor = TwiceColorImpl(defaultColor: .red500, darkColor: .gray700)
    

    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .clear, darkColor: .clear)
    var titleConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .default(of: 16, and: .semibold))
    var deliveryConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray500, font: .defaultRegularSubHeadline)
    var descriptionConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray500, font: .default(of: 14, and: .regular))
    var onlineColor: TwiceColor = TwiceColorImpl(defaultColor: .from(hex: "#4ADE80"), darkColor: .from(hex: "#4ADE80"))
}
