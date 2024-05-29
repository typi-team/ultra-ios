//
//  BaseCell.swift
//  UltraCore
//
//  Created by Slam on 4/21/23.
//

import UIKit

class BaseCell: UITableViewCell {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.setupConstraints()
        
        self.additioanSetup()
    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.setupConstraints()
        self.setupStyle()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.setupConstraints()
        self.setupStyle()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupStyle()
    }
}

extension UITableViewCell {
    
    @objc func setupStyle() {
    }
    
    @objc func additioanSetup() {
    }
    @objc func setupView() {
        
    }
    
    @objc func setupConstraints() {
        
    }
}
