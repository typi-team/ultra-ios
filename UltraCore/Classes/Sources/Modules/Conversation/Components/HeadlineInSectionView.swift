//
//  HeadlineInSectionView.swift
//  UltraCore
//
//  Created by Slam on 12/8/23.
//

import UIKit

class HeadlineInSectionView: UIView {
    
    private lazy var regularFootnote = LabelWithInsets {
        $0.textAlignment = .center
        $0.cornerRadius = kLowPadding
        $0.textInsets = UIEdgeInsets(top: 4, left: kLowPadding, bottom: 4, right: kLowPadding)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(regularFootnote)
        regularFootnote.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            regularFootnote.centerXAnchor.constraint(equalTo: centerXAnchor),
            regularFootnote.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        self.traitCollectionDidChange(UIScreen.main.traitCollection)
    }
    
    func setup(title: String) {
        self.regularFootnote.text = title
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.regularFootnote.font = UltraCoreStyle.headerInSection?.labelConfig.font
        self.regularFootnote.textColor = UltraCoreStyle.headerInSection?.labelConfig.color
        self.regularFootnote.backgroundColor = UltraCoreStyle.headerInSection?.backgroundColor.color
    }
}
