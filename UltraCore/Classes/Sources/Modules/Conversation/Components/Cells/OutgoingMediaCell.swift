//
//  OutgoingMediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/7/23.
//

import UIKit

class OutgoingMediaCell: MediaCell {
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    
    override func setupView() {
        self.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(mediaView)
        self.container.addSubview(downloadProgress)
        self.container.addSubview(deliveryWrapper)
        self.deliveryWrapper.addSubview(statusView)
        self.deliveryWrapper.addSubview(deliveryDateLabel)
    }
    
    override func setupConstraints() {

        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.left.greaterThanOrEqualToSuperview().offset(kHeadlinePadding * 4)
            
        }

        self.mediaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.constants.maxWidth)
            make.height.equalTo(self.constants.maxHeight)
        }
        
        self.downloadProgress.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }

        self.deliveryWrapper.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-kLowPadding)
            make.right.equalToSuperview().offset(-(kLowPadding + 1))
        }
        
        
        self.statusView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kLowPadding / 2)
            make.centerY.equalToSuperview()
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(statusView.snp.right).offset((kLowPadding / 2))
            make.top.equalToSuperview().offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-(kLowPadding / 2))
            make.bottom.equalToSuperview().offset(-(kLowPadding / 2))
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = .named(message.statusImageName)
        self.mediaView.image = UIImage.init(data: message.photo.preview)
        if let image = self.mediaRepository.image(from: message, with: .snapshot) {
            self.mediaView.image = image
        } else {
            self.dowloadImage(by: message)
        }
    }
}

