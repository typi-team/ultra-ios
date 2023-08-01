//
//  UltraCoreStyle.swift
//  UltraCore
//
//  Created by Slam on 7/31/23.
//

import Foundation

protocol TwiceColor {
    var defaultColor: UIColor { get set }
    var darkColor: UIColor { get set }

    var color: UIColor { get }
}

protocol LabelConfig: TwiceColor {
    var font: UIFont { get set }
}

protocol MessageCellConfig {
    var backgroundColor: TwiceColor { get set }
}

extension TwiceColor {
    var color: UIColor {
        if #available(iOS 12.0, *) {
            switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .dark:
                return darkColor
            case .light:
                return defaultColor
            default:
                return defaultColor
            }
        } else {
            return defaultColor
        }
    }
}

private class IncomeMessageCellConfigImpl: MessageCellConfig {
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .gray500)
}

private class OutcomeMessageCellConfigImpl: MessageCellConfig {
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray900)
}


private class LabelConfigImpl: LabelConfig {
    var darkColor: UIColor = .white
    var defaultColor: UIColor = .gray700
    var font: UIFont = .defaultRegularBody
    
    init(darkColor: UIColor ,
         defaultColor: UIColor,
         font: UIFont) {
        self.font = font
        self.darkColor = darkColor
        self.defaultColor = defaultColor
    }
}


private class TwiceColorImpl: TwiceColor {
    var defaultColor: UIColor
    var darkColor: UIColor
    
    init(defaultColor: UIColor, darkColor: UIColor) {
        self.defaultColor = defaultColor
        self.darkColor = darkColor
    }
}

class UltraCoreStyle {
    
//    MARK: TextButton
    static var textButtonConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)

//    MARK: UILabel
    static var headlineConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularHeadline)
    
    static var subHeadlineConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularSubHeadline)
    static var regularLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    static var regularCalloutConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCallout)
    static var regularFootnoteConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    static var regularCaption3Config: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCaption3)
    
//    MARK: UIViewContoller
    static var controllerBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    static var inputMessageBarBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    static var divederColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    
//    MARK: Message cells
    static var incomeMessageCell: MessageCellConfig = IncomeMessageCellConfigImpl()
    static var outcomeMessageCell: MessageCellConfig = OutcomeMessageCellConfigImpl()
}
