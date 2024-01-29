//
//  OutgoingMediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/7/23.
//

import UIKit
import NVActivityIndicatorView
import RxSwift

class OutgoingPhotoCell: MediaCell {

    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    
    override func setupView() {
        self.contentView.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(mediaView)
        self.mediaView.addSubview(playView)
        self.mediaView.addSubview(spinnerBackground)
        self.spinnerBackground.addSubview(spinner)
        self.container.addSubview(deliveryWrapper)
        self.deliveryWrapper.addSubview(statusView)
        self.deliveryWrapper.addSubview(deliveryDateLabel)
        self.additioanSetup()
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
        
        self.playView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kHeadlinePadding * 2)
        }

        self.spinnerBackground.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(48)
        }

        self.spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(36)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = statusImage(for: message)
        self.mediaView.image = UIImage.init(data: message.photo.preview)
        self.playView.isHidden = true
        if self.mediaRepository.isUploading(from: message) {
            self.uploadingProgress(for: message)
        } else if let image = self.mediaRepository.image(from: message) {
            self.mediaView.image = image
        } else {
            self.dowloadImage(by: message)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.spinnerBackground.isHidden = true
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

extension OutgoingPhotoCell {
    func uploadingProgress(for message: Message) {
        self.mediaView.image = self.mediaRepository.image(from: message) ??
            UIImage(data: message.photo.preview) ??
            UIImage(data: message.video.thumbPreview)
        self.spinnerBackground.isHidden = false
        self.mediaRepository
            .uploadingMedias
            .map({ $0.first(where: { $0.fileID == self.message?.fileID }) })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] request in
                guard let `self` = self, let request = request else { return  }
                if request.fromChunkNumber >= request.toChunkNumber {
                    self.spinnerBackground.isHidden = true
                } else {
                    self.spinnerBackground.isHidden = false

                }
            })
            .map({ [weak self] request -> UIImage? in
                guard let `self` = self, let message = self.message, let request = request else { return nil }

                if request.fromChunkNumber >= request.toChunkNumber {
                    return self.mediaRepository.image(from: message)
                } else {
                    return nil
                }
            })
            .compactMap({ $0 })
            .subscribe(onNext: { [weak self] image in
                guard let `self` = self else { return }
                self.mediaView.image = image
                self.playView.isHidden = !message.hasVideo
            }, onError:  { [weak self] error in
                guard let `self` = self else { return }
                self.spinnerBackground.isHidden = true
            })
            .disposed(by: disposeBag)
    }
}


class OutgoingVideoCell: OutgoingPhotoCell {
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = statusImage(for: message)
        self.mediaView.image = UIImage.init(data: message.video.thumbPreview)
        if self.mediaRepository.isUploading(from: message) {
            self.uploadingProgress(for: message)
        } else if let image = self.mediaRepository.image(from: message) {
            self.playView.isHidden = !message.hasVideo
            self.mediaView.image = image
        } else {
            if message.photo.preview.isEmpty {
                mediaView.image = mediaRepository.videoPreview(from: message)
                return
            }
            self.dowloadImage(by: message)
        }
    }
    
}
