//
//  TextFields.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit
class CustomTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding.left, dy: padding.right)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding.left, dy: padding.right)
    }
}
