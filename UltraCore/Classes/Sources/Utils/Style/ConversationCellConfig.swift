//
//  ConversationCellConfig.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol ConversationCellConfig {
    var titleConfig: LabelConfig { get set }
    var deliveryConfig: LabelConfig { get set }
    var backgroundColor: TwiceColor { get set }
    var descriptionConfig: LabelConfig { get set }
}
