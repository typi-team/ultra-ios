//
//  ProfileNavigationView.swift
//  UltraCore
//
//  Created by Slam on 5/10/23.
//

import Foundation

class ProfileNavigationView: UIView {
    
    fileprivate var conversation: Conversation?
    fileprivate let headlineText: HeadlineBody = .init()
    fileprivate let sublineText: RegularFootnote = .init()
    
    fileprivate let avatarImageView: UIImageView = .init {
        $0.borderWidth = 1
        $0.cornerRadius = 20
        $0.borderColor = .green500
        $0.frame.size = .init(width: 40, height: 40)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.setupConstraints()
    }
    
    func setupConstraints() {
        self.avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(kLowPadding / 2))
        }
        
        self.headlineText.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(self.avatarImageView.snp.top)
            make.left.equalTo(self.avatarImageView.snp.right).offset(kMediumPadding)
        }
        
        self.sublineText.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.avatarImageView.snp.bottom)
            make.top.equalTo(self.headlineText.snp.bottom).offset(kLowPadding / 2)
            make.left.equalTo(self.avatarImageView.snp.right).offset(kMediumPadding)
        }
    }
    
    func setupView() {
        self.addSubview(sublineText)
        self.addSubview(headlineText)
        self.addSubview(avatarImageView)
    }
    
    func setup(conversation: Conversation) {
        self.conversation = conversation
        self.headlineText.text = conversation.title
        self.sublineText.text = conversation.lastMessage?.description
        if let contact = conversation.peer {
            self.avatarImageView.config(contact: contact)
        } else {
            self.avatarImageView.loadImage(by: nil, placeholder: .initial(text: conversation.title))
        }
        
        if let contact = conversation.peer {
            self.sublineText.text = contact.status.displayText
            self.sublineText.textColor = contact.status.color
        }
    }
    
    func setup(user typing: UserTypingWithDate) {
        if typing.isTyping {
            self.sublineText.textColor = .gray500
            self.sublineText.text = "Печатает ... "
        } else if let conversation = self.conversation {
            self.setup(conversation: conversation)
        }
    }
}

extension UserStatus {
    var displayText: String {
        switch status {
        case .unknown:
            return "Неизвестно"
        case .online:
            return "онлайн"
        case .offline:
            return self.lastSeen.date(format: .dayAndHourMinute)
        case .away:
            return self.lastSeen.date(format: .dayAndHourMinute)
        case .UNRECOGNIZED:
            return self.lastSeen.date(format: .dayAndHourMinute)
        }
    }
    
    var color: UIColor {
        switch status {
        case .online: return .green600
        default: return .gray500
        }
    }
}