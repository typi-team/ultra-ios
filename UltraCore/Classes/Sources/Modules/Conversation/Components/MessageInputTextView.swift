//
//  MessageInputTextView.swift
//  UltraCore
//
//  Created by Typi on 06.02.2024.
//

import UIKit

protocol MessageInputTextViewDelegate: UITextViewDelegate {
    func textViewDidChangeHeight(_ textView: MessageInputTextView, height: CGFloat)
}

class MessageInputTextView: UITextView {
    private var heightConstraint: NSLayoutConstraint?
    private var oldText: String = ""
    private var oldSize: CGSize = .zero
    
    var maxHeight: CGFloat = 120
    var placeholderText: String? {
        didSet { setNeedsDisplay() }
    }
    var placeholderColor: UIColor = .gray500 {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentMode = .redraw
        associateConstraints()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange(notification:)),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: heightConstraint?.constant ?? 30)
    }
    
    private func associateConstraints() {
        for constraint in constraints {
            if constraint.firstAttribute == .height && constraint.relation == .equal {
                heightConstraint = constraint
            }
        }
    }
    
    private func forceLayoutSubviews() {
        oldSize = .zero
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if text == oldText && bounds.size == oldSize {
            return
        }
        
        oldText = text
        oldSize = bounds.size
        
        let size = sizeThatFits(CGSize(width: bounds.size.width, height: .greatestFiniteMagnitude))
        var height = size.height
        
        height = min(height, maxHeight)
        
        if heightConstraint == nil {
            heightConstraint = NSLayoutConstraint(
                item: self,
                attribute: .height,
                relatedBy: .equal, 
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: height
            )
            addConstraint(heightConstraint!)
        }
        
        if height != heightConstraint?.constant {
            heightConstraint?.constant = height
            if let delegate = delegate as? MessageInputTextViewDelegate {
                delegate.textViewDidChangeHeight(self, height: height)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard 
            text.isEmpty,
            let placeholderText = placeholderText
        else {
            return
        }
        
        // placeholder
        let xVal = textContainerInset.left + textContainer.lineFragmentPadding
        let yVal = textContainerInset.top
        let width = rect.size.width - xVal - textContainerInset.right
        let height = rect.size.height - yVal - textContainerInset.bottom
        let placeholderFrame = CGRect(x: xVal, y: yVal, width: width, height: height)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .paragraphStyle: paragraphStyle
        ]
        if let font = font {
            attributes[.font] = font
        }
        
        placeholderText.draw(in: placeholderFrame, withAttributes: attributes)
    }
    
    @objc func textDidChange(notification: Notification) {
        guard notification.object is MessageInputTextView else {
            return
        }
        
        setNeedsDisplay()
    }
    
}
