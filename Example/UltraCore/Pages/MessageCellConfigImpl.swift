//
//  MessageCellConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

struct MessageCellConfigImpl: MessageCellConfig {
    var textLabelConfig: LabelConfig = LabelConfigImpl()

    var deliveryLabelConfig: LabelConfig = LabelConfigImpl()

    var backgroundColor: TwiceColor = TwiceColorImpl.init(defaultColor: .blue, darkColor: .brown)

    var sildirBackgroundColor: TwiceColor = TwiceColorImpl.init(defaultColor: .blue, darkColor: .brown)
}
