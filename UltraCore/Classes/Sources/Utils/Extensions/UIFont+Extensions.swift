//
//  UIFont+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/18/23.
//

import Foundation

extension UIFont {

    class var defaultRegularHeadline: UIFont {
        return UIFont.systemFont(ofSize: 18.0, weight: .regular)
    }

    class var defaultRegularBody: UIFont {
        return UIFont.systemFont(ofSize: 17.0, weight: .regular)
    }

    class var defaultRegularCallout: UIFont {
        return UIFont.systemFont(ofSize: 16.0, weight: .regular)
    }

    class var defaultRegularFootnote: UIFont {
        return UIFont.systemFont(ofSize: 13.0, weight: .regular)
    }

    class var defaultRegularCaption3: UIFont {
        return UIFont.systemFont(ofSize: 10.0, weight: .regular)
    }
}
