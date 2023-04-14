//
//  Labels.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit

// Создаем кастомные классы UILabel
class BoldLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = boldFont
    }
}

class RegularLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = regularFont
    }
}

class HeadlineLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = headlineFont
    }
}
