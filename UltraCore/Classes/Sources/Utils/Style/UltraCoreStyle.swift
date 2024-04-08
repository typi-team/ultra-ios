//
//  UltraCoreStyle.swift
//  UltraCore
//
//  Created by Slam on 7/31/23.
//

import UIKit

private class IncomeMessageCellConfigImpl: MessageCellConfig {
    var fileIconImage: TwiceImage? = TwiceImageImpl(dark: UIImage.named("contact_file_icon")!, default: UIImage.named("contact_file_icon")!)
    
    var loadingImage: TwiceImage?  = TwiceImageImpl.init(dark: .named("conversation_status_loading")!, default: .named("conversation_status_loading")!)
    var sentImage: TwiceImage?  = TwiceImageImpl.init(dark: .named("conversation_status_sent")!, default: .named("conversation_status_sent")!)
    var deliveredImage: TwiceImage?  = TwiceImageImpl.init(dark: .named("conversation_status_delivered")!, default: .named("conversation_status_delivered")!)
    var readImage: TwiceImage?  = TwiceImageImpl.init(dark: .named("conversation_status_read")!, default: .named("conversation_status_read")!)
    var locationMediaImage: TwiceImage? = TwiceImageImpl(dark: .named("ff_logo_text")!, default: .named("ff_logo_text")!)
    var moneyImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_money_icon")!, default: .named("conversation_money_icon")!)
    var locationPinImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_location_pin")!, default: .named("conversation_location_pin")!)
    var linkColor: TwiceColor = TwiceColorImpl(defaultColor: .systemBlue, darkColor: .systemBlue)
    
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
    var locationMediaImage: TwiceImage? = TwiceImageImpl(dark: .named("ff_logo_text")!, default: .named("ff_logo_text")!)
    var moneyImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_money_icon")!, default: .named("conversation_money_icon")!)
    var locationPinImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_location_pin")!, default: .named("conversation_location_pin")!)
    var linkColor: TwiceColor = TwiceColorImpl(defaultColor: .systemBlue, darkColor: .systemBlue)
    
    var fileIconImage: TwiceImage? = TwiceImageImpl(dark: UIImage.named("contact_file_icon")!, default: UIImage.named("contact_file_icon")!)
    
    var textLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularBody)
    var deliveryLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray900)
    var sildirBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
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
    public static var backButton: TwiceImage? = TwiceImageImpl(dark: .named("icon_back_button")!, default: .named("icon_back_button")!)
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
//    MARK: Report page config
    public static var reportCommentControllerStyle: ReportCommentControllerStyle? = ReportCommentControllerStyleImpl()
    public static var reportViewStyle: ReportViewStyle = ReportViewStyleImpl()
    public static var messageCellStyle: MessageCellStyle = ReportViewStyleImpl()
    public static var fileCellConfig: FileCellConfig = FileCellConfigImpl()
    public static var disclaimerStyle: DisclaimerStyleConfig = DisclaimerStyleConfigImpl()
    public static var editActionBottomBar: EditActionBottomBarConfig = EditActionBottomBarConfigImpl()
    public static var fileSelectionStyle: FileSelectionConfig = FileSelectionConfigImpl()
}

private class MessageInputBarConfigImpl: MessageInputBarConfig {
    var blockedViewConfig: MessageInputBarBlockedConfig = MessageInputBarBlockedConfigImpl()
    
    var textConfig: TextViewConfig = LabelConfigImpl.init(darkColor: .white, defaultColor: .gray900, font: .defaultRegularSubHeadline,
                                                          tintColor: TwiceColorImpl(defaultColor: .green500, darkColor: .white))
    var dividerColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    var sendMessageViewTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var sendMoneyViewTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var sendMoneyImage: TwiceImage = TwiceImageImpl(dark: .named("message_input_exchange")!, default: .named("message_input_exchange")!)
    var recordViewTint: TwiceColor = TwiceColorImpl(defaultColor: .gray400, darkColor: .white)
    var messageContainerBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    var sendImage: TwiceImage = TwiceImageImpl(dark: .named("conversation_send")!, default: .named("conversation_send")!)
    var plusImage: TwiceImage = TwiceImageImpl(dark: .named("conversation_plus")!, default: .named("conversation_plus")!)
    var microphoneImage: TwiceImage = TwiceImageImpl(dark: .named("message_input_micro")!, default: .named("message_input_micro")!)
}

private class MessageInputBarBlockedConfigImpl: MessageInputBarBlockedConfig {
    var dividerColor: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray700)
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray700)
    var textConfig: TextViewConfig =  LabelConfigImpl.init(darkColor: .white, defaultColor: .gray900, font: .defaultRegularSubHeadline,
                                                           tintColor: TwiceColorImpl(defaultColor: .green500, darkColor: .white))
    
    var textBackgroundConfig: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .green500)
}

private class VoiceInputBarConfigImpl: VoiceInputBarConfig {
    var background: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .white)
    var waveBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var recordBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var roundedViewBackground: TwiceColor = TwiceColorImpl(defaultColor: .gray200, darkColor: .gray100)
    var removeButtonBackground: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .white)
    var durationLabel: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray500, font: .defaultRegularBody)
}

open class CallPageStyleImpl: CallPageStyle {
    open var background: TwiceColor = TwiceColorImpl(defaultColor: .from(hex: "#0F141B"), darkColor: .from(hex: "#0F141B"))
    open var backButtonTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .green500)
    open var companionConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .white, font: .defaultRegularTitle2)
    open var durationConfig: LabelConfig = LabelConfigImpl(darkColor: .gray400, defaultColor: .gray400, font: .defaultRegularBody)
    open var companionVideoConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .white, font: .defaultRegularHeadline)
    open var durationVideoConfig: LabelConfig = LabelConfigImpl(darkColor: .gray400, defaultColor: .gray400, font: .defaultRegularFootnote)
    open var mouthpieceOnImage: UIImage = .fromAssets("calling.mouthpieceOn")!
    open var mouthpieceOffImage: UIImage = .fromAssets("calling.mouthpieceOff")!
    open var micOnImage: UIImage = .fromAssets("calling.micOn")!
    open var micOffImage: UIImage = .fromAssets("calling.micOff")!
    open var cameraOnImage: UIImage = .fromAssets("calling.cameraOn")!
    open var cameraOffImage: UIImage = .fromAssets("calling.cameraOff")!
    open var answerImage: UIImage = .fromAssets("calling.answer")!
    open var declineImage: UIImage = .fromAssets("calling.decline")!
    open var closeImage: UIImage = .fromAssets("calling.close")!
    open var switchFrontCameraImage: UIImage = .fromAssets("calling.switchCameraPosition")!
    open var switchBackCameraImage: UIImage = .fromAssets("calling.switchCameraPosition")!
    
    public init() {}
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

private class FileCellConfigImpl: FileCellConfig {
    var loaderTintColor: TwiceColor = TwiceColorImpl(defaultColor: .black, darkColor: .black)
    var loaderBackgroundColor: TwiceColor = TwiceColorImpl(
        defaultColor: .white.withAlphaComponent(0.8),
        darkColor: .white.withAlphaComponent(0.8)
    )
    var fileTextConfig: LabelConfig = LabelConfigImpl(
        darkColor: UltraCoreStyle.regularFootnoteConfig.color,
        defaultColor: UltraCoreStyle.regularFootnoteConfig.color,
        font: UltraCoreStyle.regularFootnoteConfig.font
    )
}

private class DisclaimerStyleConfigImpl: DisclaimerStyleConfig {
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .bgSurfaceMuted, darkColor: .bgSurfaceMuted)
    var warningImage: TwiceImage = TwiceImageImpl(dark: UIImage.fromAssets("conversation_warning")!, default: UIImage.fromAssets("conversation_warning")!)
    var warningTextConfig: LabelConfig = LabelConfigImpl(darkColor: .textSecondary, defaultColor: .textSecondary, font: .defaultRegularFootnote)
    var closeButtonBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .white)
    var closeButtontTextConfig: LabelConfig = LabelConfigImpl(darkColor: .baseBlue, defaultColor: .baseBlue, font: .defaultRegularCallout)
    var agreeButtonBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .uiBlueMuted, darkColor: .uiBlueMuted)
    var agreeButtonTextConfig: LabelConfig = LabelConfigImpl(darkColor: .baseBlue, defaultColor: .baseBlue, font: .defaultRegularCallout)
    var contactTextConfig: LabelConfig = LabelConfigImpl(darkColor: .textPrimary, defaultColor: .textPrimary, font: .title3)
    var contactDescriptionConfig: LabelConfig = LabelConfigImpl(darkColor: .textPrimary, defaultColor: .textPrimary, font: .defaultRegularFootnote)
}

private class EditActionBottomBarConfigImpl: EditActionBottomBarConfig {
    var trashImage: TwiceImage? = TwiceImageImpl(dark: .named("edit.action.bar.trash")!, default: .named("edit.action.bar.trash")!)
    var shareImage: TwiceImage? = TwiceImageImpl(dark: .named("edit.action.bar.share")!, default: .named("edit.action.bar.share")!)
    var replyImage: TwiceImage? = TwiceImageImpl(dark: .named("edit.action.bar.reply")!, default: .named("edit.action.bar.reply")!)
}

private class FileSelectionConfigImpl : FileSelectionConfig {
    var cameraImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_camera")!, default: .named("conversation_camera")!)
    var photoImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_photo")!, default: .named("conversation_photo")!)
    var documentImage: TwiceImage? = TwiceImageImpl(dark: .named("contact_file_icon")!, default: .named("contact_file_icon")!)
    var contactImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_user_contact")!, default: .named("conversation_user_contact")!)
    var locationImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_location")!, default: .named("conversation_location")!)
}
