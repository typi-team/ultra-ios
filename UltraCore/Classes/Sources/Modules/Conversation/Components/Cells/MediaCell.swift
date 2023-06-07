//
//  MediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/7/23.
//

import UIKit
import RxSwift

class MediaCell: BaseMessageCell {
     let deliveryWrapper: UIView = .init {
         $0.cornerRadius = 12
         $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
     }

     let mediaRepository: MediaRepository = AppSettingsImpl.shared.mediaRepository

     lazy var mediaView: UIImageView = .init {
         $0.image = .named("ff_logo_text")
         $0.contentMode = .scaleAspectFill
     }

     override func prepareForReuse() {
         super.prepareForReuse()
         self.mediaView.image = nil
     }

     func dowloadImage(by message: Message) {
         self.mediaView.image = UIImage(data: message.photo.preview)
         self.mediaRepository
             .downloadingImages
             .map({ $0.first(where: { $0.fileID == self.message?.photo.fileID }) })
             .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
             .observe(on: MainScheduler.instance)
             .map({ [weak self] request -> UIImage? in
                 guard let `self` = self, let message = self.message, request != nil else { return nil }
                 return self.mediaRepository.image(from: message, with: .origin)
             })
             .compactMap({ $0 })
             .subscribe { [weak self] image in
                 guard let `self` = self else { return }
                 self.mediaView.image = image
             }
             .disposed(by: disposeBag)
     }
}
