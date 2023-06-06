//
//  Button.swift
//  UltraCore
//
//  Created by Slam on 4/19/23.
//

import Foundation

class ElevatedButton: UIButton {
    
    // Отступы для содержимого кнопки
    let contentInsets = UIEdgeInsets(top: kMediumPadding, left: kHeadlinePadding, bottom: kMediumPadding, right: kHeadlinePadding)
    
    override func contentRect(forBounds bounds: CGRect) -> CGRect {
        // Учитываем отступы для вычисления фактической области содержимого кнопки
        let newBounds = UIEdgeInsetsInsetRect(bounds, contentInsets)
        return super.contentRect(forBounds: newBounds)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        // Учитываем отступы для вычисления фактической области заголовка кнопки
        let newContentRect = UIEdgeInsetsInsetRect(contentRect, contentInsets)
        return super.titleRect(forContentRect: newContentRect)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        // Учитываем отступы для вычисления фактической области изображения кнопки
        let newContentRect = UIEdgeInsetsInsetRect(contentRect, contentInsets)
        return super.imageRect(forContentRect: newContentRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = .green600
        self.cornerRadius = kMediumPadding
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = .defaultRegularCallout
    }
}


class TextButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.setTitleColor(.gray700, for: .normal)
        self.titleLabel?.font = .defaultRegularCallout
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.titleEdgeInsets = .init(top: 0, left: kMediumPadding + 2, bottom: 0, right: 0)
    }
}
