//
//  DisclaimerStyleConfig.swift
//  UltraCore
//
//  Created by Typi on 06.03.2024.
//

import Foundation

public protocol DisclaimerStyleConfig {
    var backgroundColor: TwiceColor { get set }
    var warningTextConfig: LabelConfig { get set }
    var closeButtonBackgroundColor: TwiceColor { get set }
    var closeButtontTextConfig: LabelConfig { get set }
    var agreeButtonBackgroundColor: TwiceColor { get set }
    var agreeButtonTextConfig: LabelConfig { get set }
    var contactTextConfig: LabelConfig { get set }
    var contactDescriptionConfig: LabelConfig { get set }
}
