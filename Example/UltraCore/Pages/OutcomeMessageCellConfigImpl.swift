//
//  OutcomeMessageCellConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

class OutcomeMessageCellConfigImpl: OutcomingMessageCellConfig {
    var statusWidth: CGFloat?
    
    var fileIconImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "contact_file_icon")!.withRenderingMode(.alwaysTemplate),
        default: .init(named: "contact_file_icon")!.withRenderingMode(.alwaysTemplate)
    )
    var loadingImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_loading")!,
        default: .init(named: "conversation_status_loading")!
    )
    var sentImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_sent")!,
        default: .init(named: "conversation_status_sent")!
    )
    var deliveredImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_delivered")!,
        default: .init(named: "conversation_status_delivered")!
    )
    var readImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_read")!,
        default: .init(named: "conversation_status_read")!
    )

   var textLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
   var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
   var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray900)
   var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var locationMediaImage: TwiceImage? = TwiceImageImpl(
        dark: .init(named: "ff_logo_text")!.withRenderingMode(.alwaysTemplate),
        default: .init(named: "ff_logo_text")!.withRenderingMode(.alwaysTemplate)
    )
    var moneyImage: TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_money_icon")!.withRenderingMode(.alwaysTemplate),
        default: .init(named: "conversation_money_icon")!.withRenderingMode(.alwaysTemplate)
    )
    var locationPinImage: TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_location_pin")!.withRenderingMode(.alwaysTemplate),
        default: .init(named: "conversation_location_pin")!.withRenderingMode(.alwaysTemplate)
    )
    var linkColor: TwiceColor = TwiceColorImpl(defaultColor: .systemBlue, darkColor: .systemBlue)
    var fileCellConfig: UltraCore.FileCellConfig = FileCellConfigImpl()
    var mediaImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_media_play")!.withRenderingMode(.alwaysTemplate),
        default: .init(named: "conversation_media_play")!.withRenderingMode(.alwaysTemplate)
    )
}
