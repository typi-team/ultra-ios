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
        font = .defaultRegularBody
    }
}

class RegularLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = .defaultRegularBody
    }
}

class HeadlineLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = .defaultRegularBody
    }
}
