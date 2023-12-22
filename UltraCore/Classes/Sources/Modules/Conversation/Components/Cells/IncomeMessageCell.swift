//
//  IncomeMessageCell.swift
//  UltraCore
//
//  Created by Slam on 5/10/23.
//

import Foundation

class IncomeMessageCell: BaseMessageCell {
    override func setup(message: Message) {
        super.setup(message: message)

        let frameWidth = self.frame.size.width
        let maxWidth = frameWidth - kMediumPadding - contentLessThanConstant
        
        let textSize = self.calculateTextSize(text: message.text, font: textView.font, maxWidth: maxWidth).width
       
        self.textView.snp.updateConstraints { make in
            make.width.equalTo(textSize)
        }
    }

    func calculateTextSize(text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return boundingBox.size
    }
}

