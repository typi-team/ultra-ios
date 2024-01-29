//
//  TwiceColor.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol TwiceColor {
    var defaultColor: UIColor { get set }
    var darkColor: UIColor { get set }

    var color: UIColor { get }
}

public extension TwiceColor {
    var color: UIColor {
        if #available(iOS 12.0, *) {
            switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .dark:
                return darkColor
            case .light:
                return defaultColor
            default:
                return defaultColor
            }
        } else {
            return defaultColor
        }
    }
}


class TwiceColorImpl: TwiceColor {
    var defaultColor: UIColor
    var darkColor: UIColor
    
    init(defaultColor: UIColor, darkColor: UIColor) {
        self.defaultColor = defaultColor
        self.darkColor = darkColor
    }
}
