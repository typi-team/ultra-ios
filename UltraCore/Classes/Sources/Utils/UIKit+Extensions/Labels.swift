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
        font = .defaultRegularFootnote
    }
}

class RegularBody: BaseLabel {
    override func setupView() {
        super.setupView()
        self.font = .defaultRegularBody
    }
}

class RegularCallout: BaseLabel {
    override func setupView() {
        super.setupView()
        self.font = .defaultRegularCallout
    }
}

class RegularFootnote: BaseLabel {
    override func setupView() {
        super.setupView()
        self.font = .defaultRegularFootnote
    }
}

class RegularCaption3: BaseLabel {
    override func setupView() {
        super.setupView()
        self.font = .defaultRegularCaption3
    }
}
