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
        case initial(text: String)
    }

    func config(contact: ContactDisplayable) {
        self.contentMode = .scaleAspectFit
        if let image = contact.image {
            self.image = image
        } else {
            self.loadImage(by: nil, placeholder: .initial(text: contact.displaName.initails))
        }
    }
    
    
    func loadImage(by path: String?, placeholder: PlaceholderType = .square) {
        self.contentMode = .scaleAspectFit
        switch placeholder {
        case .initial(text: let text):
            if let image = self.imageFromCache(forKey: text) {
                self.image = image
            }else if  let image = self.generateAvatarImage(forUsername: text, size: self.frame.size == .zero ? CGSize.init(width: 64, height: 64) : self.frame.size) {
                self.saveImageToCache(image, forKey: text)
                self.image = image
            } else {
                self.image = placeholder.image
            }
        default:
            self.image = placeholder.image
            self.sd_setImage(with: path?.url, placeholderImage: placeholder.image)
        }
    }
}

extension UIImageView {
    
    func generateAvatarImage(forUsername username: String, size: CGSize) -> UIImage? {
        let frame = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Draw circle
        context.addEllipse(in: frame)
        context.clip()
        context.setFillColor(UIColor.white.cgColor)
        context.fill(frame)
        
        // Draw initials
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.green500,
            .font: UIFont.systemFont(ofSize: size.width/2, weight: .bold)
        ]
        let initials = String(username.prefix(2)).uppercased()
        let initialsString = NSAttributedString(string: initials, attributes: attributes)
        let textSize = initialsString.size()
        let textRect = CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        initialsString.draw(in: textRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // Функция для сохранения изображения в кэш
    func saveImageToCache(_ image: UIImage?, forKey key: String) {
        guard let image = image else {
            return
        }
        let cache = SDImageCache.shared
        cache.store(image, forKey: key, toDisk: true, completion: nil)
    }

    // Функция для получения изображения из кэша по имени
    func imageFromCache(forKey key: String) -> UIImage? {
        let cache = SDImageCache.shared
        return cache.imageFromCache(forKey: key)
    }
}

extension UIImageView.PlaceholderType {
    var image: UIImage? {  UIImage.named("ff_logo_text") }
}

extension UIImage {
    static func named(_ name: String) -> UIImage? {
        return UIImage(named: name, in: AppSettingsImpl.shared.podAsset, compatibleWith: nil)
    }
}
