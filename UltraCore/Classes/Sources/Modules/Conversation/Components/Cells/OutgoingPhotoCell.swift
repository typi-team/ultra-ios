//
//  OutgoingMediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/7/23.
//

import UIKit
import RxSwift

class OutgoingPhotoCell: MediaCell {
    
    fileprivate let uploadProgressContainer: UIView = .init({
        $0.isHidden = true
        $0.cornerRadius = kLowPadding
        $0.backgroundColor = UIColor.black
    })
    
    fileprivate let uploadProgress: UIActivityIndicatorView = .init(activityIndicatorStyle: .whiteLarge)
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    
    override func setupView() {
        self.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(mediaView)
        self.container.addSubview(downloadProgress)
        self.container.addSubview(deliveryWrapper)
        self.deliveryWrapper.addSubview(statusView)
        self.deliveryWrapper.addSubview(deliveryDateLabel)
        self.container.addSubview(uploadProgressContainer)
        self.uploadProgressContainer.addSubview(uploadProgress)
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

        self.uploadProgressContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.uploadProgress.snp.makeConstraints { make in
            make.height.width.equalTo(kHeadlinePadding)
            make.top.left.equalToSuperview().offset(kLowPadding)
            make.right.bottom.equalToSuperview().offset(-kLowPadding)
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
        if self.mediaRepository.isUploading(from: message) {
            self.uploadingProgress(for: message)
        } else if let image = self.mediaRepository.image(from: message, with: .snapshot) {
            self.mediaView.image = image
        } else {
            self.dowloadImage(by: message)
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.uploadProgressContainer.isHidden = true
    }
}

extension OutgoingPhotoCell {
    func uploadingProgress(for message: Message) {
        self.mediaView.image = self.mediaRepository.image(from: message, with: .snapshot) ??
            UIImage(data: message.photo.preview) ??
            UIImage(data: message.video.thumbPreview)
        self.mediaRepository
            .uploadingImages
            .map({ $0.first(where: { $0.fileID == self.message?.photo.fileID }) })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .do(onNext: {[weak self] _ in
                self?.uploadProgressContainer.isHidden = false
            })
            .map({ [weak self] request -> UIImage? in
                guard let `self` = self, let message = self.message, let request = request else { return nil }

                if request.fromChunkNumber >= request.toChunkNumber {
                    return self.mediaRepository.image(from: message, with: .origin)
                } else {
                    return nil
                }
            })
            .compactMap({ $0 })
            .subscribe { [weak self] image in
                guard let `self` = self else { return }
                self.mediaView.image = image
                self.uploadProgressContainer.isHidden = true
            }
            .disposed(by: disposeBag)
    }
}


class OutgoingVideoCell: OutgoingPhotoCell {
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = .named(message.statusImageName)
        self.mediaView.image = UIImage.init(data: message.video.thumbPreview)
        if self.mediaRepository.isUploading(from: message) {
            self.uploadingProgress(for: message)
        } else if let image = self.mediaRepository.image(from: message, with: .snapshot) {
            self.mediaView.image = image
        } else {
            self.dowloadImage(by: message)
        }
    }
    
}
