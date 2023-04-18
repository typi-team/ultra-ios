//
//  UIImageView+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/18/23.
//

import Foundation
import SDWebImage
import AssetsLibrary
import PodAsset

extension UIImageView {
    enum PlaceholderType {
        case oval, rounded, square
    }

    func loadImage(by path: String?, placeholder: PlaceholderType = .square) {
        self.image = placeholder.image
        self.contentMode = .scaleAspectFit
        self.image = placeholder.image
        
//        self.sd_setImage(with: path?.url, placeholderImage: placeholder.image) { image, error, cacheType, url in
//            Logger.debug(image?.description ?? "")
//        }
    }
}

extension UIImageView.PlaceholderType {
//    var image: UIImage? { UIImage(named: "placeholder", in: Bundle.init(identifier: "Media"), compatibleWith: nil) }
    
    var image: UIImage? {
        return UIImage.init(named: "placeholder", in: PodAsset.bundle(forPod: "UltraCore"), compatibleWith: nil)
    }
}
