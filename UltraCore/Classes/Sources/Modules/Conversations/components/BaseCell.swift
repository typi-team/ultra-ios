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
    }
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.setupConstraints()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.setupConstraints()
    }
}

extension UITableViewCell {
    @objc func setupView() {
        
    }
    
    @objc func setupConstraints() {
        
    }
}
