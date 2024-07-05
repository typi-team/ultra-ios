//
//  CallCell.swift
//  UltraCore
//
//  Created by Typi on 20.06.2024.
//

import UIKit

class IncomeCallCell: BaseMessageCell {
    
    fileprivate var style: CallMessageCellConfig? = UltraCoreStyle.incomeCallCell
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = style?.titleConfig.font
        label.textColor = style?.titleConfig.color
        return label
    }()
    fileprivate lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = style?.subtitleConfig.font
        label.textColor = style?.subtitleConfig.color
        return label
    }()
    fileprivate lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    fileprivate let callImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    fileprivate lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [callImageView, labelStack])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    override func setupView() {
        super.setupView()
        container.addSubview(contentStack)
    }
    
    override func setupConstraints() {
        callImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        container.snp.makeConstraints {
            $0.leading.equalTo(16)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            $0.width.equalTo(230)
        }
        deliveryDateLabel.snp.makeConstraints {
            $0.trailing.bottom.equalTo(-8)
        }
        contentStack.snp.makeConstraints {
            $0.bottom.equalTo(deliveryDateLabel.snp.top)
            $0.top.equalTo(12)
            $0.leading.equalTo(8)
            $0.trailing.lessThanOrEqualTo(-8)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        
        subtitleLabel.text = ""
        let defaultString = message.isIncome ? MessageStrings.callIncoming.localized : MessageStrings.callOutgoing.localized
        
        switch message.call.status {
        case .callStatusCreated, .callStatusStarted:
            titleLabel.text = defaultString
            callImageView.image = style?.successIcon.image
        case .callStatusCanceled:
            titleLabel.text = message.isIncome ? MessageStrings.callMissed.localized : MessageStrings.callCancelled.localized
            callImageView.image = style?.failIcon.image
        case .callStatusMissed, .callStatusRejected:
            if message.isIncome {
                titleLabel.text = MessageStrings.callMissed.localized
            } else {
                titleLabel.text = defaultString
                subtitleLabel.text = MessageStrings.callNoAnswer.localized
            }
            callImageView.image = style?.failIcon.image
        case .callStatusEnded:
            titleLabel.text = defaultString
            let time = (message.call.endTime - message.call.startTime) / 1_000_000
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            subtitleLabel.text = String(format: "%02i:%02i", minutes, seconds)
            callImageView.image = style?.successIcon.image
        case .UNRECOGNIZED:
            titleLabel.text = defaultString
            callImageView.image = style?.successIcon.image
        }
        subtitleLabel.isHidden = subtitleLabel.text?.isEmpty ?? false
    }
    
}

class OutcomeCallCell: IncomeCallCell {
    
    fileprivate let statusView: UIImageView = .init({
        $0.contentMode = .scaleAspectFit
    })
    
    override func setupView() {
        self.style = UltraCoreStyle.outcomeCallCell
        super.setupView()
        container.addSubview(statusView)
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        statusView.image = message.statusImage
    }
    
    override func setupConstraints() {
        container.snp.makeConstraints {
            $0.trailing.equalTo(-16)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            $0.width.equalTo(230)
        }
        deliveryDateLabel.snp.makeConstraints {
            $0.bottom.equalTo(-8)
            $0.right.equalTo(statusView.snp.left).inset(-4)
        }
        statusView.snp.makeConstraints { make in
            make.centerY.equalTo(deliveryDateLabel.snp.centerY)
            make.width.equalTo(15).priority(.high)
            make.right.equalToSuperview().offset(-10)
        }
        contentStack.snp.makeConstraints {
            $0.bottom.equalTo(deliveryDateLabel.snp.top)
            $0.top.equalTo(12)
            $0.leading.equalTo(8)
            $0.trailing.lessThanOrEqualTo(-8)
        }
    }
}
