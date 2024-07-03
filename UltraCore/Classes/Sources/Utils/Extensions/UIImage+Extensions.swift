//
//  UIImage+Extensions.swift
//  UltraCore
//
//  Created by Baglan Daribayev on 24.01.2024.
//

import UIKit

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
//        let bundle = Bundle(for: AppSettingsImpl.self)
//        if let resourceURL = bundle.url(forResource: "UltraCore", withExtension: "bundle"),
//           let resourceBundle = Bundle(url: resourceURL) {
//            let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil)
//            return image?.withRenderingMode(.alwaysTemplate)
//        }
        return UIImage(named: name, in: AppSettingsImpl.shared.podAsset, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }

    static func fromAssets(_ name: String) -> UIImage? {
//        let bundle = Bundle(for: AppSettingsImpl.self)
//        if let resourceURL = bundle.url(forResource: "UltraCore", withExtension: "bundle"),
//           let resourceBundle = Bundle(url: resourceURL) {
//            let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil)
//            return image
//        }
        return UIImage(named: name, in: AppSettingsImpl.shared.podAsset, compatibleWith: nil)
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
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
}
