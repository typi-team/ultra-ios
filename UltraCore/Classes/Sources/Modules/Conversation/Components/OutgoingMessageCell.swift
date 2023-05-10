//
//  OutgoingMessageCell.swift
//  UltraCore
//
//  Created by Slam on 5/10/23.
//

import Foundation

class OutgoingMessageCell: BaseMessageCell {
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_message_status_read"))
    override func setupView() {
        super.setupView()
        
        self.container.addSubview(statusView)
        self.container.backgroundColor = .gray200
    }
    
    override func setupConstraints() {
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.left.greaterThanOrEqualToSuperview().offset(kHeadlinePadding * 4)
        }

        self.textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kLowPadding)
            make.top.equalToSuperview().offset(kLowPadding)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }

        self.statusView.snp.makeConstraints { make in
            make.left.equalTo(self.textView.snp.right).offset(kLowPadding / 2)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-kLowPadding)
            make.bottom.equalTo(textView.snp.bottom)
            make.width.equalTo(40)
            make.centerY.equalTo(statusView.snp.centerY)
        }
    }
}
