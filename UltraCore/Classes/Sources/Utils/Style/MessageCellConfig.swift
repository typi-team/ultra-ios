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
    var locationMediaImage: TwiceImage? { get set }
    var moneyImage: TwiceImage? { get set }
    var mediaImage: TwiceImage? { get set }
    var locationPinImage: TwiceImage? { get set }
    var linkColor: TwiceColor { get set }
    var fileCellConfig: FileCellConfig { get set }
    var contactLabelConfig: LabelConfig { get set }
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

public protocol VoiceMessageCellConfig {
    var minimumTrackTintColor: TwiceColor { get set }
    var maximumTrackTintColor: TwiceColor { get set }
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
    var loaderTintColor: TwiceColor { get set }
    var loaderBackgroundColor: TwiceColor { get set }
}

public protocol EditActionBottomBarConfig {
    var trashImage: TwiceImage? { get set }
    var shareImage: TwiceImage? { get set }
    var replyImage: TwiceImage? { get set }
}
