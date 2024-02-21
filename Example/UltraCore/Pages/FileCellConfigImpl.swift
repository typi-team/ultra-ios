//
//  FileCellConfig.swift
//  UltraCore_Example
//
//  Created by Typi on 02.02.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UltraCore

class FileCellConfigImpl: FileCellConfig {
    var loaderTintColor: TwiceColor = TwiceColorImpl(defaultColor: .black, darkColor: .black)
    var loaderBackgroundColor: TwiceColor = TwiceColorImpl(
        defaultColor: .white.withAlphaComponent(0.8),
        darkColor: .white.withAlphaComponent(0.8)
    )
    var fileTextConfig: LabelConfig = LabelConfigImpl(
        darkColor: UltraCoreStyle.regularFootnoteConfig.color,
        defaultColor: UltraCoreStyle.regularFootnoteConfig.color,
        font: UltraCoreStyle.regularFootnoteConfig.font
    )
}
