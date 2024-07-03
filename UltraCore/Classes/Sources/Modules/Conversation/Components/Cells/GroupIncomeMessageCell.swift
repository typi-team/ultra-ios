//
//  GroupIncomeMessageCell.swift
//  UltraCore
//
//  Created by Typi on 29.04.2024.
//

import UIKit

class GroupIncomeMessageCell: IncomeMessageCell {
    enum Constants {
        static let avatarSize: CGFloat = 28
    }
    private let avatarImageView = UIImageView()

    override func setupView() {
        super.setupView()
        
        contentView.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = 14
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UltraCoreStyle.defaultPlaceholder?.image
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        avatarImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(kMediumPadding)
            $0.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            $0.size.equalTo(Constants.avatarSize)
        }

        container.snp.remakeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            $0.width.lessThanOrEqualTo(bubbleWidth - Constants.avatarSize - kMediumPadding)
            $0.left.equalTo(avatarImageView.snp.right).offset(kLowPadding)
        }
    }
    
    func setup(contact: ContactDisplayable?) {
        guard let contact = contact else {
            return
        }
        
        self.messagePrefix = contact.displaName
        avatarImageView.set(contact: contact, placeholder: UltraCoreStyle.defaultPlaceholder?.image)
    }
    
    func setup(conversation: Conversation) {
        avatarImageView.sd_setImage(with: conversation.imagePath?.url, placeholderImage: UltraCoreStyle.defaultPlaceholder?.image)
    }
    
}
