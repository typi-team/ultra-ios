//
//  IncomingMediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import UIKit
import RxSwift

class IncomingMediaCell: BaseMessageCell {
    
    fileprivate let deliveryWrapper: UIView = .init{
        $0.cornerRadius = 12
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }
    fileprivate let mediaRepository: MediaRepository = AppSettingsImpl.shared.mediaRepository
    
    fileprivate lazy var mediaView: UIImageView = .init {
        $0.image = .named("ff_logo_text")
        $0.contentMode = .scaleAspectFill
    }
    
    override func setupView() {
        self.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(mediaView)
        self.container.addSubview(deliveryWrapper)
        self.deliveryWrapper.addSubview(deliveryDateLabel)
    }
    
    override func setupConstraints() {

        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.lessThanOrEqualToSuperview().offset(-120)
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
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.mediaView.image = UIImage.init(data: message.photo.preview)
        if let image = self.mediaRepository.image(from: message, with: .snapshot) {
            self.mediaView.image = image
        } else {
            self.mediaView.image = UIImage(data: message.photo.preview)
            self.mediaRepository
                .downloadingImages
                .map({ $0.first(where: { $0.fileID == self.message?.photo.fileID})})
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .observe(on: MainScheduler.instance)
                .map({ [weak self] request -> UIImage? in
                    guard let `self` = self, let message = self.message, request != nil  else { return nil }
                    return self.mediaRepository.image(from: message, with: .origin)
                })
                .compactMap({$0})
                .subscribe { [weak self] image in
                    guard let `self` = self else { return }
                    self.mediaView.image = image
                }
                .disposed(by: disposeBag)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.mediaView.image = nil
    }
}
