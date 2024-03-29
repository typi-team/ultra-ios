//
//  ElevatedButtonStyle.swift
//  UltraCore
//
//  Created by Slam on 1/8/24.
//

import Foundation

public protocol ElevatedButtonStyle {
    var backgroundColor: TwiceColor { get set }
    var titleConfig: LabelConfig { get set }
}


struct ElevatedButtonStyleImpl: ElevatedButtonStyle {
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .black, darkColor: .white)
    var titleConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .white, font: .defaultRegularCallout)
}
