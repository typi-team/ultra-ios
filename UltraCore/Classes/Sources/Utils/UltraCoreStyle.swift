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

public protocol TextViewConfig: LabelConfig {
    var tintColor: TwiceColor { get set }
    var placeholder: String { get set }
}

public protocol ConversationCellConfig {
    var titleConfig: LabelConfig { get set }
    var deliveryConfig: LabelConfig { get set }
    var backgroundColor: TwiceColor { get set }
    var descriptionConfig: LabelConfig { get set }
}

public protocol MessageCellConfig {
    var backgroundColor: TwiceColor { get set }
    var sildirBackgroundColor: TwiceColor { get set }
    var textLabelConfig: LabelConfig { get set }
    var deliveryLabelConfig: LabelConfig { get set }
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
    var textLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .gray500)
    var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
}

private class OutcomeMessageCellConfigImpl: MessageCellConfig {
    var textLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray900)
    var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
}


private struct LabelConfigImpl: TextViewConfig {
    var darkColor: UIColor = .white
    var defaultColor: UIColor = .gray700
    var font: UIFont = .defaultRegularBody
    var placeholder: String = "\(ConversationStrings.insertText.localized)..."
    var tintColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
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
    public static var divederColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
//    MARK: Conversation cell
    public static var conversationCell: ConversationCellConfig = ConversationCellConfigImpl()
//    MARK: Message cells
    public static var incomeMessageCell: MessageCellConfig = IncomeMessageCellConfigImpl()
    public static var outcomeMessageCell: MessageCellConfig = OutcomeMessageCellConfigImpl()
//    MARK: MessageInputBar config
    public static var mesageInputBarConfig: MessageInputBarConfig = MessageInputBarConfigImpl()
//    MARK: VoiceBarView config
    public static var voiceInputBarConfig: VoiceInputBarConfig = VoiceInputBarConfigImpl()
//    MARK: Calling page config
    public static var callingConfig: CallPageStyle = CallPageStyleImpl()
}



public protocol MessageInputBarConfig {
    var dividerColor: TwiceColor { get set }
    var background: TwiceColor { get set }
    var textConfig: TextViewConfig { get set }
    var sendMessageViewTint: TwiceColor { get set }
    var sendMoneyViewTint: TwiceColor { get set }
    var recordViewTint: TwiceColor { get set }
    var messageContainerBackground: TwiceColor { get set }
}

private class MessageInputBarConfigImpl: MessageInputBarConfig {
    var textConfig: TextViewConfig = LabelConfigImpl.init(darkColor: .white, defaultColor: .gray900, font: .defaultRegularSubHeadline,
                                                          tintColor: TwiceColorImpl(defaultColor: .green500, darkColor: .white))
    var dividerColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    var sendMessageViewTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var sendMoneyViewTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var recordViewTint: TwiceColor = TwiceColorImpl(defaultColor: .gray400, darkColor: .white)
    var messageContainerBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
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


public protocol CallPageStyle {
    var background: TwiceColor { get set }
    
    var companionConfig: LabelConfig { get set }
    var durationConfig: LabelConfig { get set }
    
    var mouthpieceOnImage: UIImage { get set }
    
    var mouthpieceOffImage: UIImage { get set }
    
    var micOnImage: UIImage { get set }
    var micOffImage: UIImage { get set }
    
    var cameraOnImage: UIImage { get set }
    var cameraOffImage: UIImage { get set }
    
    var answerImage: UIImage { get set }
    var declineImage: UIImage { get set }
}

private class CallPageStyleImpl: CallPageStyle {
    
//    var background: TwiceColor = TwiceColorImpl(defaultColor: .from(hex: "#0F141B"), darkColor: .from(hex: "#0F141B"))
    var background: TwiceColor = TwiceColorImpl(defaultColor: .black, darkColor: .black)
    
    var companionConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .white, font: .defaultRegularHeadline)
    
    var durationConfig: LabelConfig = LabelConfigImpl(darkColor: .gray400, defaultColor: .gray400, font: .defaultRegularBody)
    
    var mouthpieceOnImage: UIImage = .named("calling.mouthpieceOn")!
    
    var mouthpieceOffImage: UIImage = .named("calling.mouthpieceOff")!
    
    var micOnImage: UIImage = .named("calling.micOn")!
    
    var micOffImage: UIImage = .named("calling.micOff")!
    
    var cameraOnImage: UIImage = .named("calling.cameraOn")!
    
    var cameraOffImage: UIImage = .named("calling.cameraOff")!
    
    var answerImage: UIImage = .named("calling.answer")!
    
    var declineImage: UIImage = .named("calling.decline")!
    
    var closeImage: UIImage = .named("calling.close")!
}

private class ConversationCellConfigImpl: ConversationCellConfig {
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .red)
    var titleConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCallout)
    var deliveryConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var descriptionConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
}
