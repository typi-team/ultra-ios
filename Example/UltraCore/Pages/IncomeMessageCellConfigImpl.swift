//
//  IncomeMessageCellConfigImpl.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore
import UIKit

class IncomeMessageCellConfigImpl: MessageCellConfig {
    var fileIconImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "contact_file_icon")?.withRenderingMode(.alwaysTemplate),
        default: .init(named: "contact_file_icon")?.withRenderingMode(.alwaysTemplate)
    )
    var loadingImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_loading"),
        default: .init(named: "conversation_status_loading")
    )
    var sentImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_sent"),
        default: .init(named: "conversation_status_sent")
    )
    var deliveredImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_delivered"),
        default: .init(named: "conversation_status_delivered")
    )
    var readImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_status_read"),
        default: .init(named: "conversation_status_read")
    )
    var textLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCallout)
    var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .default(of: 12, and: .regular))
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .gray500)
    var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var locationMediaImage: TwiceImage? = TwiceImageImpl(
        dark: .init(named: "ff_logo_text")?.withRenderingMode(.alwaysTemplate),
        default: .init(named: "ff_logo_text")?.withRenderingMode(.alwaysTemplate)
    )
    var moneyImage: TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_money_icon")?.withRenderingMode(.alwaysTemplate),
        default: .init(named: "conversation_money_icon")?.withRenderingMode(.alwaysTemplate)
    )
    var locationPinImage: TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_location_pin")?.withRenderingMode(.alwaysTemplate),
        default: .init(named: "conversation_location_pin")?.withRenderingMode(.alwaysTemplate)
    )
    var linkColor: TwiceColor = TwiceColorImpl(defaultColor: .systemBlue, darkColor: .systemBlue)
    var fileCellConfig: UltraCore.FileCellConfig = FileCellConfigImpl()
    var mediaImage: UltraCore.TwiceImage? = TwiceImageImpl(
        dark: .init(named: "conversation_media_play")?.withRenderingMode(.alwaysTemplate),
        default: .init(named: "conversation_media_play")?.withRenderingMode(.alwaysTemplate)
    )
    var contactLabelConfig: UltraCore.LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultBoldBody)
    var textBoldFont: UIFont = UIFont.defaultBoldBody
    var textItalicFont: UIFont = UIFont.italicSystemFont(ofSize: 17.0)
    var codeSnippetConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .systemFont(ofSize: 16.0, weight: .light))
    var codeSnippetBackgroundColor: TwiceColor = TwiceColorImpl(
        defaultColor: .init(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0),
        darkColor: .init(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
    )
}
