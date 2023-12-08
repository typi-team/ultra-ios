//
//  VoiceInputBarConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

class VoiceInputBarConfigImpl: VoiceInputBarConfig {
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .white)
    var waveBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var recordBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var roundedViewBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray100)
    var removeButtonBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var durationLabel: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray500, font: .defaultRegularBody)
}
