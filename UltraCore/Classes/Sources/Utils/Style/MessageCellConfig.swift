//
//  MessageCellConfig.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol MessageCellConfig {
    var fileIconImage: TwiceImage? { get set }
    var backgroundColor: TwiceColor { get set }
    var sildirBackgroundColor: TwiceColor { get set }
    var textLabelConfig: LabelConfig { get set }
    var deliveryLabelConfig: LabelConfig { get set }
    
}

public protocol OutcomingMessageCellConfig: MessageCellConfig {
    var loadingImage: TwiceImage? { get set }
    var sentImage: TwiceImage? { get set }
    var deliveredImage: TwiceImage? { get set }
    var readImage: TwiceImage? { get set }
    var statusWidth: CGFloat? { get set }
}

public protocol VideoFotoCellConfig  {
    var placeholder: TwiceImage? { get set }
    var playImage: TwiceImage? { get set }
    var containerBackgroundColor: TwiceColor { get set }
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

public protocol ConversationHeaderConfig {
    var titleConfig: LabelConfig { get set }
    var sublineConfig: LabelConfig { get set }
    var onlineColor: TwiceColor {get set }
}

public protocol FileCellConfig {
    var fileTextConfig: LabelConfig { get set }
}
