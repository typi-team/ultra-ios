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
        $0.cornerRadius = 30
        $0.contentMode = .scaleAspectFit
    })
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    
    fileprivate let titleView: UILabel = .init({
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .gray700
        $0.font = .default(of: 16, and: .semibold)
    })
    
    fileprivate let descriptionView: UILabel = .init({
        $0.numberOfLines = 2
        $0.textColor = .gray500
        $0.font = .default(of: 14, and: .regular)
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    })
    
    fileprivate let lastSeenView: UILabel = .init({
        $0.textAlignment = .right
        $0.textColor = .green500
        $0.font = .defaultRegularSubHeadline
    })
    
    fileprivate let unreadView: LabelWithInsets = .init({
        $0.textInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        $0.cornerRadius = 11
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .defaultRegularSubHeadline
        $0.backgroundColor = .green500
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    })
    
    fileprivate lazy var onlineView: UIView = {
        let view = UIView()
        view.cornerRadius = 6
        view.backgroundColor = style?.onlineColor.color
        return view
    }()
    
    fileprivate lazy var onlineContentView: UIView = {
        let view = UIView()
        view.backgroundColor = UltraCoreStyle.controllerBackground?.color
        view.cornerRadius = 10
        return view
    }()
    
    override func setupView() {
        super.setupView()
        self.contentView.addSubview(self.avatarView)
        self.contentView.addSubview(self.titleView)
        self.contentView.addSubview(self.descriptionView)
        self.contentView.addSubview(self.statusView)
        self.contentView.addSubview(self.lastSeenView)
        self.contentView.addSubview(self.unreadView)
        self.contentView.addSubview(self.onlineContentView)
        self.onlineContentView.addSubview(onlineView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.avatarView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.size.equalTo(60)
        }
        self.titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(kHeadlinePadding)
            make.left.equalTo(self.avatarView.snp.right).offset(kMediumPadding)
            make.right.lessThanOrEqualTo(self.statusView.snp.left).offset(-kLowPadding).priority(.high)
        }

        self.statusView.snp.makeConstraints { make in
            make.width.equalTo(0)
            make.centerY.equalTo(self.lastSeenView.snp.centerY)
        }
        
        self.lastSeenView.snp.makeConstraints { make in
            make.top.centerY.equalTo(titleView)
            make.width.greaterThanOrEqualTo(kHeadlinePadding)
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding)
            make.right.equalToSuperview().inset(kMediumPadding)
        }

        self.descriptionView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.left.equalTo(avatarView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(-3.5*kMediumPadding)
        }

        self.unreadView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(kMediumPadding)
            make.top.equalTo(titleView.snp.bottom).offset(6)
        }
        onlineContentView.snp.makeConstraints { make in
            make.bottom.right.equalTo(avatarView)
            make.size.equalTo(20)
        }
        onlineView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(12)
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
        self.onlineContentView.isHidden = !(conversation.peers.first?.status.isOnline ?? false)
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
            PP.debug("Set conversation avatar - \(conversation.imagePath?.url) for \(conversation.title)")
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
        guard let style else { return }
        self.backgroundColor = style.backgroundColor.color
        self.descriptionView.textColor = style.descriptionConfig.color
        self.descriptionView.font = style.descriptionConfig.font
        self.titleView.textColor = style.titleConfig.color
        self.titleView.font = style.titleConfig.font
        self.lastSeenView.font = style.deliveryConfig.font
        self.lastSeenView.textColor = style.deliveryConfig.color
        self.unreadView.backgroundColor = style.unreadBackgroundColor.color
        self.onlineContentView.backgroundColor = UltraCoreStyle.controllerBackground?.color
        self.onlineView.backgroundColor = style.onlineColor.color
    }
}
