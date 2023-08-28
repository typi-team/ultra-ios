//
//  UltraCoreStyle.swift
//  UltraCore
//
//  Created by Slam on 7/31/23.
//

import Foundation

public protocol TwiceColor {
    var defaultColor: UIColor { get set }
    var darkColor: UIColor { get set }

    var color: UIColor { get }
}

public protocol LabelConfig: TwiceColor {
    var font: UIFont { get set }
}

public protocol MessageCellConfig {
    var backgroundColor: TwiceColor { get set }
    var sildirBackgroundColor: TwiceColor { get set }
}

public extension TwiceColor {
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
    var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
}

private class OutcomeMessageCellConfigImpl: MessageCellConfig {
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray900)
    var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
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

public class UltraCoreStyle {
//    MARK: TextButton
    public static var textButtonConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
//    MARK: UILabel
    public static var headlineConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularHeadline)
    public static var subHeadlineConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularSubHeadline)
    public static var regularLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    public static var regularCalloutConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCallout)
    public static var regularFootnoteConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    public static var regularCaption3Config: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCaption3)
//    MARK: UIViewContoller
    public static var controllerBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    public static var inputMessageBarBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    public static var divederColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
//    MARK: Message cells
    public static var incomeMessageCell: MessageCellConfig = IncomeMessageCellConfigImpl()
    public static var outcomeMessageCell: MessageCellConfig = OutcomeMessageCellConfigImpl()
//    MARK: VoiceBarView config
    public static var voiceInputBarConfig: VoiceInputBarConfig = VoiceInputBarConfigImpl()
}


public protocol VoiceInputBarConfig {
    var background: TwiceColor { get set }
    var waveBackground: TwiceColor { get set }
    var durationLabel: LabelConfig { get set }
    var recordBackground: TwiceColor { get set }
    var roundedViewBackground: TwiceColor { get set }
    var removeButtonBackground: TwiceColor { get set }
}


private class VoiceInputBarConfigImpl: VoiceInputBarConfig {
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .white)
    var waveBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var recordBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var roundedViewBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray100)
    var removeButtonBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var durationLabel: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray500, font: .defaultRegularBody)
}
