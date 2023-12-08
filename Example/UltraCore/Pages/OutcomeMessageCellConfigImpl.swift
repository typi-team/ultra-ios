//
//  OutcomeMessageCellConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

class OutcomeMessageCellConfigImpl: MessageCellConfig {
    var loadingImage: UltraCore.TwiceImage?
    
    var sentImage: UltraCore.TwiceImage?
    
    var deliveredImage: UltraCore.TwiceImage?
    
    var readImage: UltraCore.TwiceImage?
    
   var textLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
   var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
   var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray900)
   var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
}
