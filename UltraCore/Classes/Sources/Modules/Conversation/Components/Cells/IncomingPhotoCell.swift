//
//  IncomingMediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import UIKit

class IncomingPhotoCell: MediaCell {
    
    override func setupView() {
        self.contentView.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(mediaView)
        self.container.addSubview(playView)
        self.container.addSubview(spinnerBackground)
        self.container.addSubview(deliveryWrapper)
        self.deliveryWrapper.addSubview(deliveryDateLabel)
        self.spinnerBackground.addSubview(spinner)
        self.additioanSetup()
    }
    
    override func setupConstraints() {

        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.width.lessThanOrEqualTo(bubbleWidth)
        }

        self.mediaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.constants.maxWidth)
            make.height.equalTo(self.constants.maxHeight)
        }

        self.deliveryWrapper.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-kLowPadding)
            make.right.equalToSuperview().offset(-(kLowPadding + 1))
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kLowPadding / 2)
            make.top.equalToSuperview().offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-(kLowPadding / 2))
            make.bottom.equalToSuperview().offset(-(kLowPadding / 2))
        }

        self.spinnerBackground.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(48.0)
        }

        self.spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(36.0)
        }

        self.playView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kHeadlinePadding * 2)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.playView.isHidden = true
        self.mediaView.image = message.previewImage
        if let image = self.mediaRepository.previewImage(from: message) {
            self.mediaView.image = image
        } else {
            self.dowloadImage(by: message)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        if let style = UltraCoreStyle.videoFotoMessageCell {
            self.deliveryWrapper.backgroundColor = style.containerBackgroundColor.color
            self.deliveryDateLabel.textColor = style.deliveryLabelConfig.color
            self.deliveryDateLabel.font = style.deliveryLabelConfig.font
            
            if let playImage = style.playImage?.image {
                self.playView.image = playImage
            }
        }
    }
}


class IncomingVideoCell: IncomingPhotoCell {
    override func setup(message: Message) {
        super.setup(message: message)
        if let image = self.mediaRepository.image(from: message) {
            self.playView.isHidden = !message.hasVideo
        }
    }
}
