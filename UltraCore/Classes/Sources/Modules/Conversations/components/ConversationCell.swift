//
//  ConversationCell.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import UIKit

class ConversationCell: BaseCell {
    
    fileprivate lazy var style: ConversationCellConfig? = UltraCoreStyle.conversationCell
    
    fileprivate let avatarView: UIImageView = .init({
        $0.cornerRadius = 20
        $0.contentMode = .scaleAspectFit
        
    })
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    
    fileprivate let titleView: UILabel = .init({
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingTail
    })
    
    fileprivate let descriptionView: UILabel = .init({
        $0.numberOfLines = 1
    })
    
    fileprivate let lastSeenView: UILabel = .init({
        $0.textAlignment = .right
    })
    
    fileprivate let unreadView: LabelWithInsets = .init({
        $0.cornerRadius = 9
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .defaultRegularFootnote
        $0.backgroundColor = .green500
    })
    
    
    override func setupView() {
        super.setupView()
        self.contentView.addSubview(self.avatarView)
        self.contentView.addSubview(self.titleView)
        self.contentView.addSubview(self.descriptionView)
        self.contentView.addSubview(self.statusView)
        self.contentView.addSubview(self.lastSeenView)
        self.contentView.addSubview(self.unreadView)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(40)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        self.titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(kHeadlinePadding)
            make.left.equalTo(self.avatarView.snp.right).offset(kMediumPadding)
            make.right.lessThanOrEqualTo(self.statusView.snp.left).offset(-kLowPadding).priority(.high)
        }

        self.statusView.snp.makeConstraints { make in
            make.width.equalTo(0)
            make.centerY.equalTo(self.lastSeenView.snp.centerY)
        }
        
        self.lastSeenView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarView.snp.top)
            make.width.greaterThanOrEqualTo(kHeadlinePadding)
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
        }

        self.descriptionView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(titleView.snp.bottom).offset(2)
            make.left.equalTo(avatarView.snp.right).offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-10)
        }

        self.unreadView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.height.equalTo(18)
            make.width.equalTo(24)
            make.left.equalTo(descriptionView.snp.right).offset(kMediumPadding)
            make.bottom.greaterThanOrEqualTo(self.descriptionView.snp.bottom)
        }
    }
    
    func setup(conversation: Conversation, isManager: Bool) {
        self.titleView.text = conversation.title
        self.descriptionView.text = conversation.lastMessage?.message ?? getNoMessagesText(isManager: isManager)
        self.unreadView.isHidden = conversation.unreadCount == 0
        self.unreadView.text = conversation.unreadCount.description
        self.lastSeenView.text = conversation.timestamp.formattedTimeForConversationCell()
        self.setupTyping(conversation: conversation, isManager: isManager)
        self.setupAvatar(conversation: conversation)
        
        if let message = conversation.lastMessage, !message.isIncome {
            self.statusView.image = message.statusImage
            self.statusView.snp.updateConstraints { make in
                make.width.equalTo(message.stateViewWidth)
            }
        } else {
            self.statusView.snp.updateConstraints { make in
                make.width.equalTo(0)
            }
        }
    }
    
    private func getNoMessagesText(isManager: Bool) -> String {
        return isManager ? ConversationStrings.noMessagesManager.localized : ConversationStrings.noMessages.localized
    }
    
    private func setupAvatar(conversation: Conversation) {
        if conversation.chatType != .peerToPeer {
            self.avatarView.sd_setImage(with: conversation.imagePath?.url, placeholderImage: UltraCoreStyle.defaultPlaceholder?.image)
        }
        else if let contact = conversation.peers.first {
            self.avatarView.set(contact: contact, placeholder: UltraCoreStyle.defaultPlaceholder?.image)
        } else {
            self.avatarView.set(placeholder: .initial(text: conversation.title))
        }
    }
    
    private func setupTyping(conversation: Conversation, isManager: Bool) {
        let typingUsers = conversation.typingData.filter({$0.isTyping})
        if typingUsers.isEmpty {
            self.descriptionView.text = conversation.lastMessage?.message ?? getNoMessagesText(isManager: isManager)
        } else {
            self.descriptionView.text = "\(ConversationStrings.prints.localized)"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarView.image = nil
        self.unreadView.text = ""
        self.avatarView.sd_cancelCurrentImageLoad()
    }
    
    override func setupStyle() {
        super.setupStyle()
        self.descriptionView.textColor = style?.descriptionConfig.color
        self.descriptionView.font = style?.descriptionConfig.font
        self.backgroundColor = style?.backgroundColor.color
        self.titleView.textColor = style?.titleConfig.color
        self.titleView.font = style?.titleConfig.font
        self.lastSeenView.font = style?.deliveryConfig.font
        self.lastSeenView.textColor = style?.deliveryConfig.color
        self.unreadView.backgroundColor = style?.unreadBackgroundColor.color
    }
}
