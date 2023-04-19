//
//  TextFields.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit

class CustomTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
