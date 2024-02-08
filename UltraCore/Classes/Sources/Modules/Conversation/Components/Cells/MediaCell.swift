//
//  MediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/7/23.
//

import UIKit
import NVActivityIndicatorView
import RxSwift

class MediaCell: BaseMessageCell {
    
    let playView: UIImageView = .init {
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
        $0.image = .named("conversation_media_play")
    }

    let deliveryWrapper: UIView = .init {
        $0.cornerRadius = 12
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

    let spinnerBackground: UIView = .init {
        $0.backgroundColor = UltraCoreStyle.fileCellConfig.loaderBackgroundColor.color
        $0.isHidden = true
        $0.cornerRadius = 24
    }

    lazy var spinner: NVActivityIndicatorView = makeSpinner()

    let mediaRepository: MediaRepository = AppSettingsImpl.shared.mediaRepository

    lazy var mediaView: UIImageView = .init {
        $0.contentMode = .scaleAspectFill
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.mediaView.image = nil
        self.playView.isHidden = true
        self.spinnerBackground.isHidden = true
    }

    func dowloadImage(by message: Message) {
        self.mediaView.image = UIImage(data: message.photo.preview)
        self.spinnerBackground.isHidden = false
        self.mediaRepository
            .downloadingImages
            .map({ $0.first(where: { $0.fileID == self.message?.fileID }) })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] request in
                guard let `self` = self, let request = request else { return }
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
            .subscribe { [weak self] image in
                guard let `self` = self else { return }
                self.mediaView.image = self.mediaRepository.previewImage(from: message)
                self.playView.isHidden = !message.hasVideo
            }
            .disposed(by: disposeBag)
    }
    
    func statusImage(for message: Message)  -> UIImage? {
        if let style = UltraCoreStyle.videoFotoMessageCell {
            if message.seqNumber == 0 {
                return style.loadingImage?.image ?? message.statusImage
            } else if message.state.delivered == false && message.state.read == false {
                return style.sentImage?.image ?? message.statusImage
            } else if message.state.delivered == true && message.state.read == false {
                return style.deliveredImage?.image ?? message.statusImage
            } else {
                return style.readImage?.image ?? message.statusImage
            }
        } else {
            return message.statusImage
        }
    }

    func makeSpinner() -> NVActivityIndicatorView {
        let spinner = NVActivityIndicatorView(
            frame: CGRect(origin: .zero, size: .init(width: 36, height: 36)),
            type: .circleStrokeSpin,
            color: UltraCoreStyle.fileCellConfig.loaderTintColor.color,
            padding: 0
        )
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        return spinner
    }
}
