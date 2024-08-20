//
//  MessageCellConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

struct VideoFotoCellConfigImpl : VideoFotoCellConfig {
    
    var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .gray700, defaultColor: .gray700, font: .defaultRegularFootnote)
    
    var loadingImage: TwiceImage?  = TwiceImageImpl.init(dark: UIImage.init(named: "conversation_status_loading"), default: UIImage.init(named: "conversation_status_loading"))
    var sentImage: TwiceImage?  = TwiceImageImpl.init(dark: UIImage.init(named: "conversation_status_sent"), default: UIImage.init(named: "conversation_status_sent"))
    var deliveredImage: TwiceImage?  = TwiceImageImpl.init(dark: UIImage.init(named: "conversation_status_delivered"), default: UIImage.init(named: "conversation_status_delivered"))
    var readImage: TwiceImage?  = TwiceImageImpl.init(dark: UIImage.init(named: "conversation_status_read"), default: UIImage.init(named: "conversation_status_read"))
    
    var placeholder: UltraCore.TwiceImage?
    
    var playImage: UltraCore.TwiceImage?
    
    var containerBackgroundColor: UltraCore.TwiceColor = TwiceColorImpl(defaultColor: .white.withAlphaComponent(0.7), darkColor: .white)
}
