//
//  BaseMessageCell.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import UIKit

class BaseMessageCell: BaseCell {
    let textView: SubHeadline = .init({$0.numberOfLines = 0})
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
            make.left.top.equalToSuperview().offset(kHeadlinePadding)
            make.bottom.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        
        self.textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kLowPadding)
            make.right.equalToSuperview().offset(-kLowPadding)
            make.top.equalToSuperview().offset(kLowPadding)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalTo(textView.snp.bottom).offset(kLowPadding)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }
    }
    
    func setup(message: Message) {
        self.textView.text = message.text
        self.deliveryDateLabel.text = message.meta.created.formattedTime()
    }
}
