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
    var fileCellConfig: FileCellConfig = FileCellConfigImpl()
    var mediaImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_media_play")!, default: .named("conversation_media_play")!)
    var contactLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultBoldBody)
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
    var fileCellConfig: FileCellConfig = FileCellConfigImpl()
    var mediaImage: TwiceImage? = TwiceImageImpl(dark: .named("conversation_media_play")!, default: .named("conversation_media_play")!)
    var contactLabelConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultBoldBody)
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
    public static var title3Config: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .textPrimary, font: .title3)
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
    public static var incomeVoiceMessageCell: VoiceMessageCellConfig? = IncomeVoiceMessageCellConfigImpl()
    public static var outcomeVoiceMessageCell: VoiceMessageCellConfig? = OutcomeVoiceMessageCellConfigImpl()
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
    public static var filePageConfig: FilesControllerConfig? = FilesControllerConfigImpl()
//    MARK: Report page config
    public static var reportCommentControllerStyle: ReportCommentControllerStyle? = ReportCommentControllerStyleImpl()
    public static var reportViewStyle: ReportViewStyle = ReportViewStyleImpl()
    public static var messageCellStyle: MessageCellStyle = ReportViewStyleImpl()
    public static var disclaimerStyle: DisclaimerStyleConfig = DisclaimerStyleConfigImpl()
    public static var editActionBottomBar: EditActionBottomBarConfig = EditActionBottomBarConfigImpl()
    public static var conversationScreenConfig: ConversationScreenStyleConfig = ConversationScreenStyleConfigImpl()
    public static var iconClose: TwiceImage = TwiceImageImpl(dark: .named("icon_close")!, default: .named("icon_close")!)
    public static var sheetGripColor: TwiceColor = TwiceColorImpl(
        defaultColor: UIColor.from(hex: "e5e7eb").withAlphaComponent(0.5),
        darkColor: UIColor.from(hex: "e5e7eb").withAlphaComponent(0.5)
    )
    public static var systemMessageTextConfig: LabelConfig = LabelConfigImpl(darkColor: .textTertiary, defaultColor: .textTertiary, font: .defaultRegularFootnote)
    public static var incomeCallCell: CallMessageCellConfig? = IncomeCallCellConfigImpl()
    public static var outcomeCallCell: CallMessageCellConfig? = OutcomeCallCellConfigImpl()
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
    var messageTextViewBorderColor: TwiceColor = TwiceColorImpl(defaultColor: .from(hex: "#DBDEE3"), darkColor: .from(hex: "#DBDEE3"))
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
    var recordButtonDefaultImage: TwiceImage = TwiceImageImpl(dark: UIImage.named("message_input_micro")!, default: UIImage.named("message_input_micro")!)
    var recordButtonRecordingImage: TwiceImage = TwiceImageImpl(dark: UIImage.named("voice.recording")!, default: UIImage.named("voice.recording")!)
    var smallMicImage: TwiceImage = TwiceImageImpl(dark: UIImage.named("mic_red")!, default: UIImage.named("mic_red")!)
    var bucketLidImage: TwiceImage = TwiceImageImpl(dark: UIImage.named("bucket_lid")!, default: UIImage.named("bucket_lid")!)
    var bucketBodyImage: TwiceImage = TwiceImageImpl(dark: UIImage.named("bucket_body")!, default: UIImage.named("bucket_body")!)
}

open class CallPageStyleImpl: CallPageStyle {
    open var background: TwiceColor = TwiceColorImpl(defaultColor: .from(hex: "#0F141B"), darkColor: .from(hex: "#0F141B"))
    open var backButtonTint: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .green500)
    open var companionConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .white, font: .defaultRegularTitle2)
    open var durationConfig: LabelConfig = LabelConfigImpl(darkColor: .gray400, defaultColor: .gray400, font: .defaultRegularBody)
    open var companionVideoConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .white, font: .defaultRegularHeadline)
    open var durationVideoConfig: LabelConfig = LabelConfigImpl(darkColor: .gray400, defaultColor: .gray400, font: .defaultRegularFootnote)
    open var mouthpieceOnImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.mouthpieceOn")!, default: .fromAssets("calling.mouthpieceOn")!)
    open var mouthpieceOffImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.mouthpieceOff")!, default: .fromAssets("calling.mouthpieceOff")!)
    open var micOnImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.micOn")!, default: .fromAssets("calling.micOn")!)
    open var micOffImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.micOff")!, default: .fromAssets("calling.micOff")!)
    open var cameraOnImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.cameraOn")!, default: .fromAssets("calling.cameraOn")!)
    open var cameraOffImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.cameraOff")!, default: .fromAssets("calling.cameraOff")!)
    open var answerImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.answer")!, default: .fromAssets("calling.answer")!)
    open var declineImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.decline")!, default: .fromAssets("calling.decline")!)
    open var closeImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.close")!, default: .fromAssets("calling.close")!)
    open var switchFrontCameraImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.switchCameraPosition")!, default: .fromAssets("calling.switchCameraPosition")!)
    open var switchBackCameraImage: TwiceImage = TwiceImageImpl(dark: .fromAssets("calling.switchCameraPosition")!, default: .fromAssets("calling.switchCameraPosition")!)
    
    public init() {}
}

private class ConversationCellConfigImpl: ConversationCellConfig {
    var unreadBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .green500, darkColor: .clear)
    
    var avatarPlaceholder: TwiceImage? = nil
    
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .gray700)
    var titleConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularCallout)
    var deliveryConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var descriptionConfig: LabelConfig = LabelConfigImpl(darkColor: .white, defaultColor: .gray700, font: .defaultRegularFootnote)
    var onlineColor: TwiceColor = TwiceColorImpl(defaultColor: .from(hex: "#4ADE80"), darkColor: .from(hex: "#4ADE80"))
    var loadingImage: TwiceImage? = TwiceImageImpl(
        dark: .named("conversation_status_loading")!,
        default: .named("conversation_status_loading")!
    )
    var sentImage: TwiceImage? = TwiceImageImpl(
        dark: .named("conversation_status_sent")!,
        default: .named("conversation_status_sent")!
    )
    var deliveredImage: TwiceImage? = TwiceImageImpl(
        dark: .named("conversation_status_delivered")!,
        default: .named("conversation_status_delivered")!
    )
    var readImage: TwiceImage? = TwiceImageImpl(
        dark: .named("conversation_status_read")!,
        default: .named("conversation_status_read")!
    )
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

private class FilesControllerConfigImpl : FilesControllerConfig {
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray100)
    var takePhotoImage: TwiceImage = TwiceImageImpl(dark: .named("conversation_camera")!, default: .named("conversation_camera")!)
    var fromGalleryImage: TwiceImage = TwiceImageImpl(dark: .named("conversation_photo")!, default: .named("conversation_photo")!)
    var documentImage: TwiceImage = TwiceImageImpl(dark: .named("contact_file_icon")!, default: .named("contact_file_icon")!)
    var contactImage: TwiceImage = TwiceImageImpl(dark: .named("conversation_user_contact")!, default: .named("conversation_user_contact")!)
    var locationImage: TwiceImage = TwiceImageImpl(dark: .named("conversation_location")!, default: .named("conversation_location")!)
}

private class ConversationScreenStyleConfigImpl: ConversationScreenStyleConfig {
    var startConversationImage: TwiceImage = TwiceImageImpl(
        dark: .named("conversation_new_icon")!,
        default: .named("conversation_new_icon")!
    )
    var conversationOptionsImage: TwiceImage = TwiceImageImpl(
        dark: .named("conversation.dots")!,
        default: .named("conversation.dots")!
    )
    var conversationVideoCallImage: TwiceImage = TwiceImageImpl(
        dark: .named("conversation_video_camera_icon")!,
        default: .named("conversation_video_camera_icon")!
    )
    var conversationVoiceCallImage: TwiceImage = TwiceImageImpl(
        dark: .named("contact_phone_icon")!,
        default: .named("contact_phone_icon")!
    )
    var loaderTintColor: TwiceColor = TwiceColorImpl(
        defaultColor: .black,
        darkColor: .black
    )
}

private class IncomeVoiceMessageCellConfigImpl: VoiceMessageCellConfig {
    var minimumTrackTintColor: TwiceColor = TwiceColorImpl(
        defaultColor: .baseBlue,
        darkColor: .baseBlue
    )
    var maximumTrackTintColor: TwiceColor = TwiceColorImpl(
        defaultColor: .from(hex: "#B7BCC5"),
        darkColor: .from(hex: "#B7BCC5")
    )
}

private class OutcomeVoiceMessageCellConfigImpl: VoiceMessageCellConfig {
    var minimumTrackTintColor: TwiceColor = TwiceColorImpl(
        defaultColor: .white,
        darkColor: .white
    )
    var maximumTrackTintColor: TwiceColor = TwiceColorImpl(
        defaultColor: .from(hex: "#BFDBFE"),
        darkColor: .from(hex: "#BFDBFE")
    )
}

private class IncomeCallCellConfigImpl: CallMessageCellConfig {
    var titleConfig: LabelConfig = LabelConfigImpl(
        darkColor: .gray700,
        defaultColor: .gray700,
        font: .defaultRegularBoldSubHeadline
    )
    var subtitleConfig: LabelConfig = LabelConfigImpl(
        darkColor: .gray500,
        defaultColor: .gray500,
        font: .defaultRegularFootnote
    )
    var failIcon: TwiceImage = TwiceImageImpl(
        dark: .fromAssets("call_fail")!,
        default: .fromAssets("call_fail")!
    )
    var successIcon: TwiceImage = TwiceImageImpl(
        dark: .fromAssets("call_income_success")!,
        default: .fromAssets("call_income_success")!
    )
}

private class OutcomeCallCellConfigImpl: CallMessageCellConfig {
    var titleConfig: LabelConfig = LabelConfigImpl(
        darkColor: .gray700,
        defaultColor: .gray700,
        font: .defaultRegularBoldSubHeadline
    )
    var subtitleConfig: LabelConfig = LabelConfigImpl(
        darkColor: .gray500,
        defaultColor: .gray500,
        font: .defaultRegularFootnote
    )
    var failIcon: TwiceImage = TwiceImageImpl(
        dark: .fromAssets("call_fail")!,
        default: .fromAssets("call_fail")!
    )
    var successIcon: TwiceImage = TwiceImageImpl(
        dark: .fromAssets("call_outcome_success")!,
        default: .fromAssets("call_outcome_success")!
    )
}
