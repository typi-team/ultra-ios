//
//  UltraCoreStyle.swift
//  UltraCore
//
//  Created by Slam on 7/31/23.
//

import UIKit

private class IncomeMessageCellConfigImpl: MessageCellConfig {
    var loadingImage: TwiceImage?  = TwiceImageImpl.init(dark: .named("conversation_status_loading")!, default: .named("conversation_status_loading")!)
    var sentImage: TwiceImage?  = TwiceImageImpl.init(dark: .named("conversation_status_sent")!, default: .named("conversation_status_sent")!)
    var deliveredImage: TwiceImage?  = TwiceImageImpl.init(dark: .named("conversation_status_delivered")!, default: .named("conversation_status_delivered")!)
    var readImage: TwiceImage?  = TwiceImageImpl.init(dark: .named("conversation_status_read")!, default: .named("conversation_status_read")!)
    
    var textLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .gray500)
    var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
}

private class OutcomeMessageCellConfigImpl: OutcomingMessageCellConfig {
    var statusWidth: CGFloat?
    
    var loadingImage: TwiceImage?  = nil
    var sentImage: TwiceImage?  = nil
    var deliveredImage: TwiceImage?  = nil
    var readImage: TwiceImage?  = nil
    
    var textLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray900)
    var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
}


private struct LabelConfigImpl: TextViewConfig {
    var darkColor: UIColor = .white
    var defaultColor: UIColor = .gray700
    var font: UIFont = .defaultRegularBody
    var placeholder: String = "\(ConversationStrings.insertText.localized)"
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

private struct TwiceImageImpl: TwiceImage {
    var dark: UIImage
    var `default`: UIImage
}

public class UltraCoreStyle {
//    MARK: UIImage
    public static var defaultPlaceholder: TwiceImage?
//    MARK: TextButton
    public static var textButtonConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    public static var elevatedButtonTint: TwiceColor? = TwiceColorImpl(defaultColor: .green500, darkColor: .green500)
//    MARK: UILabel
    public static var headlineConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularHeadline)
    public static var subHeadlineConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularSubHeadline)
    public static var regularLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    public static var regularCalloutConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCallout)
    public static var regularFootnoteConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    public static var regularCaption3Config: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCaption3)
//    MARK: Conversation controller style
    public static var conversationBackgroundImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_background") ?? UIImage(), default: .named("conversation_background") ?? UIImage())
//    MARK: UIViewContoller
    public static var controllerBackground: TwiceColor? = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    public static var divederColor: TwiceColor? = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
//    MARK: Conversation cell
    public static var conversationCell: ConversationCellConfig? = ConversationCellConfigImpl()
//    MARK: Message cells
    public static var incomeMessageCell: MessageCellConfig? = IncomeMessageCellConfigImpl()
    public static var outcomeMessageCell: OutcomingMessageCellConfig? = OutcomeMessageCellConfigImpl()
    public static var videoFotoMessageCell: VideoFotoCellConfig?
//    MARK: Date header
    public static var headerInSection: HeaderInSectionConfig? = HeaderInSectionConfigImpl()
//    MARK: Conversation Profile header
    public static var conversationProfileConfig: ConversationHeaderConfig = ConversationHeaderConfigImpl()
//    MARK: MessageInputBar config
    public static var mesageInputBarConfig: MessageInputBarConfig? = MessageInputBarConfigImpl()
//    MARK: VoiceBarView config
    public static var voiceInputBarConfig: VoiceInputBarConfig? = VoiceInputBarConfigImpl()
//    MARK: Calling page config
    public static var callingConfig: CallPageStyle = CallPageStyleImpl()
//    MARK: File page config
    public static var filePageConfig: FilesControllerConfig?
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

private class VoiceInputBarConfigImpl: VoiceInputBarConfig {
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .white)
    var waveBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var recordBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var roundedViewBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray100)
    var removeButtonBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var durationLabel: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray500, font: .defaultRegularBody)
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
    var unreadBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .clear)
    
    var avatarPlaceholder: TwiceImage? = nil
    
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .gray700)
    var titleConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCallout)
    var deliveryConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var descriptionConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
}

private class HeaderInSectionConfigImpl: HeaderInSectionConfig {
    var labelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700,
                                                   font: .defaultRegularFootnote, placeholder: "",
                                                   tintColor: TwiceColorImpl(defaultColor: .clear, darkColor: .clear))
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white.withAlphaComponent(0.7), darkColor: .clear)
}

private class ConversationHeaderConfigImpl: ConversationHeaderConfig {
    var onlineColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var titleConfig: LabelConfig =  LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularHeadline)
    var sublineConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
}
