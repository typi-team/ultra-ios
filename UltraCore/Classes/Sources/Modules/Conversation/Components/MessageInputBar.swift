//
//  MessageInputBar.swift
//  UltraCore
//
//  Created by Slam on 4/25/23.
//

import Foundation

protocol MessageInputBarDelegate: AnyObject {
    func exchanges()
    func message(text: String)
    func micro(isActivated: Bool)
}

class MessageInputBar: UIView {

//    MARK: Static properties
    
    fileprivate let kTextFieldMaxHeight: CGFloat = 120
    fileprivate let kInputSendImage: UIImage? = .named("conversation_send")
    fileprivate let kInputPlusImage: UIImage? = .named("conversation_plus")
    fileprivate let kInputMicroImage: UIImage? = .named("message_input_micro")
    fileprivate let kInputExchangeImage: UIImage? = .named("message_input_exchange")
    
    private let containerStack: UIStackView = .init {
        $0.axis = .horizontal
        $0.spacing = kMediumPadding
        $0.cornerRadius = kLowPadding
        $0.backgroundColor = .gray200
    }
    
    private lazy var messageTextView: UITextView = .init {[weak self] textView in
        textView.delegate = self
        textView.backgroundColor = .gray200
        textView.cornerRadius = kLowPadding
        textView.font = .defaultRegularSubHeadline
    }
    
    private lazy var sendButton: UIButton = .init {[weak self] button in
        guard let `self` = self else { return }
        button.setImage(self.kInputPlusImage, for: .normal)
        button.addAction {
            guard let message = self.messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                    !message.isEmpty else {
                return
            }
            self.messageTextView.text = ""
            self.delegate?.message(text: message)
            self.textViewDidChange(self.messageTextView)
        }
    }
    
    private lazy var exchangesButton: UIButton = .init {[weak self] button in
        guard let `self` = self else { return }
        button.setImage(self.kInputExchangeImage, for: .normal)
        button.addAction {
            self.delegate?.exchanges()
        }
    }
    
    private lazy var microButton: UIButton = .init {[weak self] button in
        guard let `self` = self else { return }
        button.setImage(self.kInputMicroImage, for: .normal)
        button.addAction {
            guard let message = self.messageTextView.text,
                    !message.isEmpty else {
                return
            }
            self.delegate?.micro(isActivated: false)
        }
    }
    
//    MARK: Public properties
    
    weak var delegate: MessageInputBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        self.backgroundColor = .gray100
        
        self.addSubview(sendButton)
        self.addSubview(containerStack)
        self.addSubview(exchangesButton)
        self.containerStack.addArrangedSubview(messageTextView)
        self.containerStack.addArrangedSubview(microButton)
        
    }
    
    private func setupConstraints() {
        self.exchangesButton.snp.makeConstraints { make in
            make.height.width.equalTo(36)
            make.leading.equalToSuperview().offset(kLowPadding)
            make.bottom.equalToSuperview().offset(-kMediumPadding)
            
        }
        self.containerStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding)
            make.leading.equalTo(exchangesButton.snp.trailing).offset(kLowPadding)
            make.bottom.equalToSuperview().offset(-kMediumPadding)
        }
        
        self.messageTextView.snp.makeConstraints { make in
            make.height.equalTo(36)
        }

        self.sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-kLowPadding)
            make.height.width.equalTo(36)
            make.bottom.equalToSuperview().offset(-kMediumPadding)
            make.leading.equalTo(containerStack.snp.trailing).offset(kLowPadding)
        }
        
        self.microButton.snp.makeConstraints { make in
            make.width.equalTo(36)
        }
    }
}


extension MessageInputBar: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width,
                          height: .greatestFiniteMagnitude)
        let estimatedSize = textView.sizeThatFits(size)
        textView.snp.updateConstraints { make in
            make.height.equalTo(min(estimatedSize.height, kTextFieldMaxHeight))
        }
        
        if textView.text != nil || textView.text != "" {
            self.sendButton.setImage(self.kInputSendImage, for: .normal)
        }else {
            self.sendButton.setImage(self.kInputPlusImage, for: .normal)
        }
    }
}
