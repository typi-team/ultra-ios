//
//  OutgoingMessageCell.swift
//  UltraCore
//
//  Created by Slam on 5/10/23.
//

import Foundation

class OutgoingMessageCell: BaseMessageCell {
    
    fileprivate let statusView: UIImageView = .init({
        $0.contentMode = .scaleAspectFit
    })
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(statusView)
    }
    
    override func setupConstraints() {
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.width.lessThanOrEqualTo(bubbleWidth)
        }

        self.textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(kLowPadding)
            make.right.equalToSuperview().offset(-8)
        }

        self.statusView.snp.makeConstraints { make in
            make.centerY.equalTo(deliveryDateLabel.snp.centerY)
            make.width.equalTo(15).priority(.high)
            make.right.equalToSuperview().offset(-10)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(4)
            make.left.greaterThanOrEqualTo(container).offset(8)
            make.right.equalTo(statusView.snp.left).offset(-4)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = message.statusImage
    }
}
