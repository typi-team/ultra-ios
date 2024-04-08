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
    
    var fileIconImage: UltraCore.TwiceImage? 
    var loadingImage: TwiceImage?  = TwiceImageImpl.init(dark: UIImage.init(named: "conversation_status_loading")!, default: UIImage.init(named: "conversation_status_loading")!)
    var sentImage: TwiceImage?  = TwiceImageImpl.init(dark: UIImage.init(named: "conversation_status_sent")!, default: UIImage.init(named: "conversation_status_sent")!)
    var deliveredImage: TwiceImage?  = TwiceImageImpl.init(dark: UIImage.init(named: "conversation_status_delivered")!, default: UIImage.init(named: "conversation_status_delivered")!)
    var readImage: TwiceImage?  = TwiceImageImpl.init(dark: UIImage.init(named: "conversation_status_read")!, default: UIImage.init(named: "conversation_status_read")!)
    
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
}
