//
//  Labels.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit

class BaseLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    func setupView() {
        textColor = .gray500
        self.numberOfLines = 0
        font = .defaultRegularFootnote
    }
}

class HeadlineBody: BaseLabel {
    override func setupView() {
        super.setupView()
        self.numberOfLines = 0
        self.textColor = .black
        self.font = .defaultRegularHeadline
    }
}

class RegularBody: BaseLabel {
    override func setupView() {
        super.setupView()
        self.numberOfLines = 0
        self.font = .defaultRegularBody
    }
}

class RegularCallout: BaseLabel {
    override func setupView() {
        super.setupView()
        self.numberOfLines = 0
        self.textColor = .gray700
        self.font = .defaultRegularCallout
    }
}

class RegularFootnote: BaseLabel {
    override func setupView() {
        super.setupView()
        self.numberOfLines = 0
        self.textColor = .gray500
        self.font = .defaultRegularFootnote
    }
}

class RegularCaption3: BaseLabel {
    override func setupView() {
        super.setupView()
        self.font = .defaultRegularCaption3
    }
}

class SubHeadline: BaseLabel {
    override func setupView() {
        super.setupView()
        self.textColor = .gray700
        self.font = .defaultRegularSubHeadline
    }
}


class LabelWithInsets: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
}
