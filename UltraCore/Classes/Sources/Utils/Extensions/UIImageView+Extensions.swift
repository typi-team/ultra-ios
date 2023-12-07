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
        case placeholder(image:UIImage)
    }

    func set(contact: ContactDisplayable, placeholder: UIImage?) {
        self.contentMode = .scaleAspectFit
        if let path = contact.imagePath?.url {
            self.sd_setImage(with: path, placeholderImage: placeholder)
        } else {
            let enumPlace: PlaceholderType = placeholder == nil ? .initial(text: contact.displaName.initails) : .placeholder(image: placeholder!)
            self.set(placeholder: enumPlace)
        }
    }
    
    
    func set(placeholder: PlaceholderType) {
        self.contentMode = .scaleAspectFill
        self.borderWidth = placeholder.borderWidth
        
        switch placeholder {
        case let .initial(text: text):
            if let image = self.imageFromCache(forKey: text) {
                self.image = image
            } else if let image = self.generateAvatarImage(forUsername: text, size: self.frame.size == .zero ? CGSize(width: 64, height: 64) : self.frame.size) {
                self.saveImageToCache(image, forKey: text)
                self.image = image
            } else {
                self.image = placeholder.image
            }

        default:
            self.image = placeholder.image
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
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(frame)
        
        // Draw initials
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.green500,
            .font: UIFont.default(of: size.width / 2, and: .bold)
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
    var image: UIImage? {
        switch self {
        case .placeholder(let image):
            return image
        default: return UIImage.named("ff_logo_text")
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .placeholder:
            return 0
        case .oval:
            return 2
        case .rounded:
            return 1
        case .square:
            return 1
        case .initial:
            return 2
        }
    }
}

extension UIImage {
    
    func fixedOrientation() -> UIImage {
            
            if imageOrientation == .up {
                return self
            }
            
            var transform: CGAffineTransform = CGAffineTransform.identity
            
            switch imageOrientation {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: size.height)
                transform = transform.rotated(by: CGFloat.pi)
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.rotated(by: CGFloat.pi / 2)
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: size.height)
                transform = transform.rotated(by: CGFloat.pi / -2)
            case .up, .upMirrored:
                break
            }
            
            switch imageOrientation {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: size.height, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .up, .down, .left, .right:
                break
            }
            
            if let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace,
                let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                ctx.concatenate(transform)
                
                switch imageOrientation {
                case .left, .leftMirrored, .right, .rightMirrored:
                    ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                default:
                    ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                }
                if let ctxImage: CGImage = ctx.makeImage() {
                    return UIImage(cgImage: ctxImage)
                } else {
                    return self
                }
            } else {
                return self
            }
        }
    
    enum JPEGQuality: CGFloat {
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
    }

    func compress(_ jpegQuality: JPEGQuality) -> Data? { self.jpegData(compressionQuality: jpegQuality.rawValue) }

    static func named(_ name: String) -> UIImage? {
        let bundle = Bundle(for: AppSettingsImpl.self)
        if let resourceURL = bundle.url(forResource: "UltraCore", withExtension: "bundle"),
           let resourceBundle = Bundle(url: resourceURL) {
            let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil)
            return image?.withRenderingMode(.alwaysTemplate)
        }
        return UIImage(named: name, in: AppSettingsImpl.shared.podAsset, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
    
    func downsample(reductionAmount: Float) -> UIImage? {
        let image = UIKit.CIImage(image: self)
        guard let lanczosFilter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
        lanczosFilter.setValue(image, forKey: kCIInputImageKey)
        lanczosFilter.setValue(NSNumber(value: reductionAmount), forKey: kCIInputScaleKey)

        guard let outputImage = lanczosFilter.outputImage else { return nil }
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
        let scaledImage = UIImage(cgImage: context.createCGImage(outputImage, from: outputImage.extent)!)

        return scaledImage
    }
}
