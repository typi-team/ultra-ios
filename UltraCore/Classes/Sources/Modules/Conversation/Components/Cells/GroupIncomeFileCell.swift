//
//  GroupIncomeFileCell.swift
//  UltraCore
//
//  Created by Typi on 28.05.2024.
//

import UIKit

class GroupIncomeFileCell: IncomeFileCell {
    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    private let groupContainer: UIView = .init({
        $0.cornerRadius = 18
        $0.backgroundColor = .clear
    })
    
    override func setupView() {
        super.setupView()
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(groupContainer)
//        groupContainer.addSubview(titleLabel)
        groupContainer.addSubview(container)
        avatarImageView.layer.cornerRadius = 14
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UltraCoreStyle.defaultPlaceholder?.image
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        avatarImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(kMediumPadding)
            $0.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            $0.size.equalTo(GroupIncomeMessageCell.Constants.avatarSize)
        }
        groupContainer.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            $0.width.lessThanOrEqualTo(bubbleWidth - GroupIncomeMessageCell.Constants.avatarSize - kMediumPadding)
            $0.left.equalTo(avatarImageView.snp.right).offset(kLowPadding)
        }
        container.snp.remakeConstraints {
//            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.top.bottom.left.right.equalToSuperview()
        }
//        titleLabel.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(8)
//            $0.leading.equalToSuperview().offset(10)
//            $0.trailing.equalToSuperview().offset(-10)
//        }
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        titleLabel.font = UltraCoreStyle.incomeMessageCell?.contactLabelConfig.font
        titleLabel.textColor = UltraCoreStyle.incomeMessageCell?.contactLabelConfig.color
        groupContainer.backgroundColor = container.backgroundColor
    }
}
