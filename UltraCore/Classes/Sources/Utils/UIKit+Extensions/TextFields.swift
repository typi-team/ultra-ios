//
//  TextFields.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit

class PaddingTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.tintColor = .green500
    }
    
    var padding = UIEdgeInsets(top: kMediumPadding, left: kHeadlinePadding, bottom: kMediumPadding, right: kHeadlinePadding)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds.inset(by: padding)
        let rightViewRect = rightViewRect(forBounds: bounds)
        rect.size.width -= rightViewRect.width + kLowPadding
        return rect
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds.inset(by: padding)
        let rightViewRect = rightViewRect(forBounds: bounds)
        rect.size.width -= rightViewRect.width + kLowPadding
        return rect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 36, y: 0, width: 24 , height: bounds.height)
    }
}

class PhoneNumberTextField: PaddingTextField, UITextFieldDelegate {

    var changesCallback: VoidCallback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.keyboardType = .phonePad
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = newString
        self.changesCallback?()
        return false
    }

    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex

        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}


extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
}
