//
//  FileCellConfig.swift
//  UltraCore_Example
//
//  Created by Typi on 02.02.2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UltraCore

class FileCellConfigImpl: FileCellConfig {
    var fileTextConfig: LabelConfig = LabelConfigImpl(
        darkColor: UltraCoreStyle.regularFootnoteConfig.color,
        defaultColor: UltraCoreStyle.regularFootnoteConfig.color,
        font: UltraCoreStyle.regularFootnoteConfig.font
    )
}
