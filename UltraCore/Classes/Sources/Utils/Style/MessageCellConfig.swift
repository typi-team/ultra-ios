//
//  MessageCellConfig.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol MessageCellConfig {
    var backgroundColor: TwiceColor { get set }
    var sildirBackgroundColor: TwiceColor { get set }
    var textLabelConfig: LabelConfig { get set }
    var deliveryLabelConfig: LabelConfig { get set }
    
    var loadingImage: TwiceImage? { get set }
    var sentImage: TwiceImage? { get set }
    var deliveredImage: TwiceImage? { get set }
    var readImage: TwiceImage? { get set }
}

public protocol HeaderInSectionConfig {
    var labelConfig: LabelConfig { get set }
    var backgroundColor: TwiceColor { get set }
}
