//
//  MessageInputBar.swift
//  UltraCore
//
//  Created by Slam on 4/25/23.
//

import Foundation

protocol MessageInputBarDelegate: VoiceInputBarDelegate {
    func unblock()
    func exchanges()
    func message(text: String)
    func typing(is active: Bool)
    func pressedDone(in view: MessageInputBar)
    func pressedPlus(in view: MessageInputBar)
}

class MessageInputBar: UIView {

    var isRecording: Bool {
        return audioRecordUtils.isRecording
    }
    
    var canSendAttachments: Bool = true {
        didSet {
            self.textViewDidChange(self.messageTextView)
        }
    }
    var canSendMoney: Bool = true {
        didSet {
            let isAvailable = futureDelegate?.availableToSendMoney() ?? true && canSendMoney
            exchangesButton.snp.updateConstraints {
                $0.width.equalTo(isAvailable ? 40 : 0)
            }
        }
    }
    var isEnabled: Bool = true {
        didSet {
            sendButton.isEnabled = isEnabled
            sendButton.alpha = isEnabled ? 1 : 0.25
        }
    }
    
//    MARK: Static properties
    
    fileprivate var lastTypingDate: Date = .init()
    fileprivate let kTextFieldMaxHeight: CGFloat = 120
    fileprivate lazy var kInputSendImage: UIImage? = style?.sendImage.image
    fileprivate lazy var kInputPlusImage: UIImage? = style?.plusImage.image
    fileprivate lazy var kInputMicroImage: UIImage? = style?.microphoneImage.image
    
    fileprivate lazy var audioRecordUtils: AudioRecordUtils = .init({
        $0.delegate = self
    })
    
    private var style: MessageInputBarConfig? { UltraCoreStyle.mesageInputBarConfig }
    private lazy var divider: UIView = .init { $0.backgroundColor = style?.dividerColor.color }
    
    private lazy var containerStack: UIView = .init {
        $0.cornerRadius = 18
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = style?.messageTextViewBorderColor.color.cgColor
    }
    
    private lazy var messageTextView: MessageInputTextView = MessageInputTextView.init {[weak self] textView in
        textView.delegate = self
        textView.inputAccessoryView = UIView()
        textView.placeholderText = self?.style?.textConfig.placeholder ?? ""
        textView.textColor = .gray900
        textView.tintColor = .green500
        textView.font = .defaultRegularCallout
    }
    
    private lazy var sendButton: UIButton = .init {[weak self] button in
        guard let self else { return }
        button.setImage(self.kInputPlusImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 18)
        button.addAction {
            guard let message = self.messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                    !message.isEmpty else {
                if self.canSendAttachments {
                    self.delegate?.pressedPlus(in: self)
                }
                return
            }
            self.messageTextView.text = ""
            self.delegate?.message(text: message)
            self.textViewDidChange(self.messageTextView)
        }
    }
    
    private lazy var exchangesButton: UIButton = .init { [weak self] button in
        guard let self else { return }
        button.setImage(style?.sendMoneyImage.image, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addAction {
            self.delegate?.exchanges()
        }
        
        if let availableToSendMoney = self.futureDelegate?.availableToSendMoney() {
            button.isHidden = !availableToSendMoney
        }
    }
    
    private lazy var recordView: RecordView = .init({ [weak self] in
        guard let self else { return }
        $0.delegate = self
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
        $0.slideToCancelText = ActionStrings.decline.localized
    })
    
    private lazy var microButton: RecordButton = .init {[weak self] button in
        guard let `self` = self else { return }
        button.recordView = self.recordView
        button.clipsToBounds = false
    }
    
    private lazy var blockView: BlockView = BlockView.init {
        $0.delegate = self
    }
    
    private var bottomInset: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }

    private var microButtonWidth: CGFloat {
        (UltraCoreSettings.futureDelegate?.availableToRecordVoice() ?? true) ? 36 : 0
    }
    private var tempText: String?

//    MARK: Public properties
    
    weak var delegate: MessageInputBarDelegate?
    weak var futureDelegate: UltraCoreFutureDelegate? = UltraCoreSettings.futureDelegate
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
        self.setupStyle()
        self.traitCollectionDidChange(UIScreen.main.traitCollection)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        self.backgroundColor = style?.background.color
        self.messageTextView.font = style?.textConfig.font
        self.messageTextView.textColor = style?.textConfig.color
        self.divider.backgroundColor = style?.dividerColor.color
        self.blockView.backgroundColor = style?.background.color
        self.containerStack.backgroundColor = style?.messageContainerBackground.color
        self.messageTextView.backgroundColor = style?.messageContainerBackground.color
        self.messageTextView.tintColor = style?.textConfig.tintColor.color
        self.messageTextView.layer.borderColor = style?.messageTextViewBorderColor.color.cgColor
    }
    
    private func hideOrShowAllViewInRecording(visibility: Bool) {
        self.sendButton.isHidden = !visibility
        self.exchangesButton.isHidden = !visibility
        self.messageTextView.alpha = !visibility ?  0 : 1
        self.containerStack.backgroundColor = visibility ? style?.messageContainerBackground.color : style?.background.color
        self.messageTextView.backgroundColor = visibility ? style?.messageContainerBackground.color : style?.background.color
    }
    
    private func setupViews() {
        self.addSubview(divider)
        self.addSubview(sendButton)
        self.addSubview(containerStack)
        insertSubview(exchangesButton, belowSubview: containerStack)
        self.addSubview(recordView)
        self.containerStack.addSubview(messageTextView)
        insertSubview(microButton, aboveSubview: containerStack)
        
        self.backgroundColor = UltraCoreStyle.controllerBackground?.color
    }
    
    private func setupConstraints() {
        
        let availableToSendMoney = self.futureDelegate?.availableToSendMoney() ?? true && canSendMoney
        
        self.exchangesButton.snp.makeConstraints { make in
            make.height.equalTo(36)
            
            make.leading.equalToSuperview().offset(18)
            make.bottom.equalTo(messageTextView.snp.bottom)
            make.width.equalTo(availableToSendMoney ? 40 : 0)
        }

        self.divider.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }

        self.containerStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding - 4)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 4 + bottomInset))
            make.leading.equalTo(exchangesButton.snp.trailing).offset(-4)
            make.height.greaterThanOrEqualTo(36)
        }

        self.messageTextView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kLowPadding)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kLowPadding)
        }

        self.sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(48)
            make.height.equalTo(36)
            make.bottom.equalTo(containerStack)
            make.left.equalTo(containerStack.snp.right)
        }
        self.microButton.snp.makeConstraints { make in
            make.size.equalTo(microButtonWidth)
            make.bottom.equalTo(containerStack)
            make.right.equalTo(containerStack).offset(-kLowPadding)
        }
        
        self.recordView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomInset)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalTo(microButton.snp.right)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupStyle()
    }
}


extension MessageInputBar: MessageInputTextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {

        if let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.microButton.isHidden = true
            self.sendButton.setImage(self.kInputSendImage, for: .normal)
        } else {
            if canSendAttachments {
                self.microButton.isHidden = false
                self.sendButton.setImage(self.kInputPlusImage, for: .normal)
            } else {
                self.microButton.isHidden = true
                self.sendButton.setImage(self.kInputSendImage, for: .normal)
            }
        }

        if Date().timeIntervalSince(lastTypingDate) > kTypingMinInterval {
            self.lastTypingDate = Date()
            self.delegate?.typing(is: true)
        }
    }
    
    func textViewDidChangeHeight(_ textView: MessageInputTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear) {
            self.layoutIfNeeded()
        }
    }
    
}

extension MessageInputBar {
    
    func block(_ isBlocked: Bool) {
        self.blockView.snp.makeConstraints { make in
            if isBlocked {
                guard !subviews.contains(blockView) else {
                    return
                }
                self.tempText = messageTextView.text
                self.messageTextView.text = ""
                self.messageTextView.setNeedsDisplay()
                self.addSubview(blockView)
                self.blockView.bringSubviewToFront(self)
                self.blockView.snp.makeConstraints { make in
                    make.top.left.right.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-bottomInset)
                }
            } else {
                guard subviews.contains(blockView) else {
                    return
                }
                if let tempText = tempText {
                    messageTextView.text = tempText
                    self.tempText = nil
                }
                self.blockView.removeFromSuperview()
            }
        }
    }
}

extension MessageInputBar: AudioRecordUtilsDelegate {
    func recordedVoice(url: URL, in duration: TimeInterval) {
        self.delegate?.recordedVoice(url: url, in: duration)
    }
    
    func requestRecordPermissionIsFalse() {
        delegate?.showVoiceError()
        onCancel()
    }
    
    func recordingVoice(average power: Float) {
        
    }
    
    func recodedDuration(time interal: TimeInterval) {
        
    }
    
    func cancelRecord() {
        onCancel()
    }
}

extension MessageInputBar: BlockViewDelegate {
    func unblock() {
        self.delegate?.unblock()
    }
}

extension MessageInputBar: RecordViewDelegate {
    func onStart() {
        AppSettingsImpl.shared.voiceRepository.stop()
        self.recordView.isHidden = false
        self.recordView.bringSubviewToFront(self)
        self.recordView.isUserInteractionEnabled = true
        self.hideOrShowAllViewInRecording(visibility: false)
        self.audioRecordUtils.requestRecordPermission()
        self.containerStack.borderWidth = 0
    }
    
    func onCancel() {
        self.recordView.isHidden = true
        self.recordView.isUserInteractionEnabled = false
        self.hideOrShowAllViewInRecording(visibility: true)
        self.audioRecordUtils.cancelRecording()
        self.containerStack.borderWidth = 1
    }
    
    func onFinished(duration: CGFloat) {
        self.recordView.isHidden = true
        self.recordView.isUserInteractionEnabled = false
        self.recordView.sendSubviewToBack(self)
        self.hideOrShowAllViewInRecording(visibility: true)
        self.audioRecordUtils.stopRecording()
        self.containerStack.borderWidth = 1
    }
}
