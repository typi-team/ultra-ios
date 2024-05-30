//
//  GroupIncomePhotoCell.swift
//  UltraCore
//
//  Created by Typi on 28.05.2024.
//

import UIKit

class GroupIncomePhotoCell: IncomingPhotoCell {
    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override func setupView() {
        super.setupView()
        
        contentView.addSubview(avatarImageView)
        container.addSubview(titleLabel)
        avatarImageView.layer.cornerRadius = 14
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UltraCoreStyle.defaultPlaceholder?.image
        mediaView.layer.cornerRadius = 16
        mediaView.clipsToBounds = true
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        avatarImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(kMediumPadding)
            $0.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            $0.size.equalTo(GroupIncomeMessageCell.Constants.avatarSize)
        }
        container.snp.remakeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            $0.width.lessThanOrEqualTo(bubbleWidth - GroupIncomeMessageCell.Constants.avatarSize - kMediumPadding)
            $0.left.equalTo(avatarImageView.snp.right).offset(kLowPadding)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        mediaView.snp.remakeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-2)
            $0.bottom.equalToSuperview().offset(-2)
        }
    }
    
    func setup(contact: ContactDisplayable?) {
        guard let contact = contact else {
            return
        }
        
        titleLabel.text = contact.displaName
        avatarImageView.set(contact: contact, placeholder: UltraCoreStyle.defaultPlaceholder?.image)
    }
    
    func setup(conversation: Conversation) {
        titleLabel.text = conversation.title
        avatarImageView.sd_setImage(with: conversation.imagePath?.url, placeholderImage: UltraCoreStyle.defaultPlaceholder?.image)
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        titleLabel.font = UltraCoreStyle.incomeMessageCell?.contactLabelConfig.font
        titleLabel.textColor = UltraCoreStyle.incomeMessageCell?.contactLabelConfig.color
    }
    
}

class GroupIncomingVideoCell: GroupIncomePhotoCell {
    override func setup(message: Message) {
        super.setup(message: message)
        if let image = self.mediaRepository.image(from: message) {
            self.playView.isHidden = !message.hasVideo
        }
    }
}

