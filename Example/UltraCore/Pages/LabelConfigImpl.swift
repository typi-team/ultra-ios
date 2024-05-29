//
//  LabelConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

struct LabelConfigImpl: TextViewConfig {
    var darkColor: UIColor = .white
    var defaultColor: UIColor = .gray500
    var font: UIFont = .defaultRegularBody
    var placeholder: String = "Сообщение..."
    var tintColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
}
