//
//  ConversationCell.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import UIKit

class ConversationCell: BaseCell {
    
    fileprivate let avatarView: UIImageView = .init({
        $0.borderWidth = 2
        $0.cornerRadius = 20
        $0.borderColor = .green500
        $0.contentMode = .scaleAspectFit
        
    })
    
    fileprivate let titleView: RegularCallout = .init()
    fileprivate let descriptionView: RegularFootnote = .init()
    fileprivate let lastSeenView: RegularFootnote = .init()
    fileprivate let unreadView: LabelWithInsets = .init({
        $0.font = .defaultRegularFootnote
        $0.textColor = .white
        $0.textInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        $0.backgroundColor = .green500.withAlphaComponent(0.3)
        $0.cornerRadius = 10
    })
    
    
    override func setupView() {
        super.setupView()
        self.contentView.addSubview(self.avatarView)
        self.contentView.addSubview(self.titleView)
        self.contentView.addSubview(self.descriptionView)
        self.contentView.addSubview(self.lastSeenView)
        self.contentView.addSubview(self.unreadView)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(40)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        self.titleView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarView.snp.top)
            make.left.equalTo(self.avatarView.snp.right).offset(kMediumPadding)
        }

        self.lastSeenView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarView.snp.top)
            make.left.equalTo(self.titleView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
        }

        self.descriptionView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(titleView.snp.bottom).offset(kLowPadding)
            make.left.equalTo(avatarView.snp.right).offset(kMediumPadding)
            make.bottom.greaterThanOrEqualTo(avatarView.snp.bottom)
        }

        self.unreadView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.left.equalTo(descriptionView.snp.right).offset(kMediumPadding)
            make.bottom.greaterThanOrEqualTo(self.descriptionView.snp.bottom)
        }
    }
    
    func setup(conversation: Conversation ) {
        self.titleView.text = conversation.title
        self.descriptionView.text = conversation.lastMessage
        self.unreadView.isHidden = conversation.unreadCount == 0
        self.unreadView.text = conversation.unreadCount.description
        self.lastSeenView.text = conversation.timestamp.formattedTime()
        self.avatarView.loadImage(by: nil, placeholder: .initial(text: conversation.title))
        
        self.setupTyping(conversation: conversation)
    }
    
    private func setupTyping(conversation: Conversation) {
        let typingUsers = conversation.typingData.filter({$0.isTyping})
        if typingUsers.isEmpty {
            self.descriptionView.text = conversation.lastMessage
        } else {
            self.descriptionView.text = "Печатает ..."
        }
    }
}
