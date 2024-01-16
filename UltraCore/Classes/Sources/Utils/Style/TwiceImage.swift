//
//  TwiceImage.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol TwiceImage {
    var `default`: UIImage { get set }
    var dark: UIImage { get set }

    var image: UIImage { get }
}

public extension TwiceImage {
    var image: UIImage {
        if #available(iOS 12.0, *) {
            switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            case .light:
                return self.default
            default:
                return self.default
            }
        } else {
            return self.default
        }
    }
}

struct TwiceImageImpl: TwiceImage {
    var dark: UIImage
    var `default`: UIImage
}
