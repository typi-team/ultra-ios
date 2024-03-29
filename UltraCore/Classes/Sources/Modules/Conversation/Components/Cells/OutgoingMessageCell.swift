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
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(kLowPadding)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }

        self.statusView.snp.makeConstraints { make in
            make.left.equalTo(self.textView.snp.right).offset(kLowPadding / 2)
            make.width.equalTo(15).priority(.high)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(textView.snp.bottom)
            make.width.greaterThanOrEqualTo(35)
            make.centerY.equalTo(statusView.snp.centerY)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = message.statusImage
        
        self.statusView.snp.updateConstraints { make in
            make.width.equalTo(message.stateViewWidth).priority(.high)
        }
    }
}
