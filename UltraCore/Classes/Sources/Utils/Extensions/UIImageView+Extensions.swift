//
//  UIImageView+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/18/23.
//

import Foundation
import SDWebImage

extension UIImageView {
    enum PlaceholderType {
        case oval, rounded, square
    }

    func loadImage(by path: String?, placeholder: PlaceholderType = .square) {
        self.image = placeholder.image
        self.contentMode = .scaleAspectFit

        self.sd_setImage(with: path?.url, placeholderImage: placeholder.image) { image, error, cacheType, url in
            Logger.debug(image?.description ?? "")
        }
    }
}

extension UIImageView.PlaceholderType {
    var image: UIImage? {  UIImage.named("ff_logo_text") }
}

extension UIImage {
    static func named(_ name: String) -> UIImage? {
        return UIImage(named: name, in: AppSettings.shared.podAsset, compatibleWith: nil)
    }
}
