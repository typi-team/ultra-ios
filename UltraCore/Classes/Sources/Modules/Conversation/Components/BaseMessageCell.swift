//
//  BaseMessageCell.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import UIKit
import RxSwift


struct MediaMessageConstants {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
}

class BaseMessageCell: BaseCell {
    var message: Message?
    var actionCallback: ((Message?) -> Void)?
    lazy var disposeBag: DisposeBag = .init()
    lazy var constants: MediaMessageConstants = .init(maxWidth: 300, maxHeight: 200)
    
    let textView: SubHeadline = .init({
        $0.numberOfLines = 0
    })
    
    let deliveryDateLabel: RegularFootnote = .init()
    
    let container: UIView = .init({
        $0.cornerRadius = 18
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
            make.right.lessThanOrEqualToSuperview().offset(-120)
        }

        self.textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kLowPadding)
            make.left.equalToSuperview().offset(kLowPadding + 2)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.bottom.equalTo(textView.snp.bottom)
            make.right.equalToSuperview().offset(-(kLowPadding + 1))
            make.left.equalTo(textView.snp.right).offset(kMediumPadding - 5)
        }
    }
    
    func setup(message: Message) {
        self.message = message
        self.textView.text = message.text
        self.deliveryDateLabel.text = message.meta.created.dateBy(format: .hourAndMinute)
    }
}
