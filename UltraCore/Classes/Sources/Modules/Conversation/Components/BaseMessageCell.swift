//
//  BaseMessageCell.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import UIKit

class BaseMessageCell: BaseCell {
    let textView: SubHeadline = .init({
        $0.numberOfLines = 0
    })
    
    let deliveryDateLabel: RegularFootnote = .init()
    
    let container: UIView = .init({
        $0.cornerRadius = kLowPadding
        $0.backgroundColor = .white
    })
    
    override func setupView() {
        super.setupView()
        self.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(textView)
        self.container.addSubview(deliveryDateLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.lessThanOrEqualToSuperview()
        }
        
        self.textView.snp.makeConstraints { make in 
            make.top.equalToSuperview().offset(kLowPadding)
            make.left.equalToSuperview().offset(kLowPadding + 2)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(textView.snp.centerY)
            make.left.equalTo(textView.snp.right).offset(kMediumPadding - 5)
            make.right.equalToSuperview().offset(-(kLowPadding + 1))
        }
    }
    
    func setup(message: Message) {
        self.textView.text = message.text
        self.deliveryDateLabel.text = message.meta.created.formattedTime(format: .hourAndMinute)
    }
}
