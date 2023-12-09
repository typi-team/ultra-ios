//
//  StyleSetting.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

func setDefaultStyleSettings() {
    
    let whiteConversationBackgroundImage = UIImage.init(named:"conversation_background") ?? UIImage()
    let conversationBackgroundImage = TwiceImageImpl(dark:whiteConversationBackgroundImage , default: whiteConversationBackgroundImage)
    
    UltraCoreStyle.conversationBackgroundImage = conversationBackgroundImage
    
    UltraCoreStyle.controllerBackground = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    UltraCoreStyle.divederColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    UltraCoreStyle.conversationCell = ConversationCellConfigImpl()
    UltraCoreStyle.incomeMessageCell = IncomeMessageCellConfigImpl()
    UltraCoreStyle.videoFotoMessageCell = VideoFotoCellConfigImpl()
    UltraCoreStyle.outcomeMessageCell = OutcomeMessageCellConfigImpl()
    UltraCoreStyle.mesageInputBarConfig = MessageInputBarConfigImpl()
    UltraCoreStyle.voiceInputBarConfig = VoiceInputBarConfigImpl()
    
    UltraCoreStyle.defaultPlaceholder = TwiceImageImpl(dark: UIImage(named: "user-avatar")!, default: UIImage(named: "user-avatar")!)
    UltraCoreStyle.elevatedButtonTint = TwiceColorImpl(defaultColor: .black, darkColor: .black)
    
    UltraCoreAppearance.imageViewTint = .black
    UltraCoreAppearance.buttonTint = .black
    UltraCoreAppearance.sliderTint = .black
    UltraCoreAppearance.barButtonTint = .black
    UltraCoreAppearance.navigationBarTitleTextAttributes = LabelConfigImpl(darkColor: .white, defaultColor: .black)
}
