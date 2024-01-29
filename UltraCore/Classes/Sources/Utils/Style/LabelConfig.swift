//
//  LabelConfig.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol LabelConfig: TwiceColor {
    var font: UIFont { get set }
}


struct LabelConfigImpl: TextViewConfig {
    var darkColor: UIColor = .white
    var defaultColor: UIColor = .gray700
    var font: UIFont = .defaultRegularBody
    var placeholder: String = "\(ConversationStrings.insertText.localized)"
    var tintColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
}
