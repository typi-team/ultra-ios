//
//  SystemMessageCell.swift
//  UltraCore
//
//  Created by Typi on 19.04.2024.
//

import UIKit

class SystemMessageCell: BaseCell {
    private let label: UILabel = .init {
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override func setupView() {
        super.setupView()
        contentView.addSubview(label)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectedBackgroundView = UIView({
            $0.backgroundColor = .clear
        })
        label.font = UltraCoreStyle.systemMessageTextConfig.font
        label.textColor = UltraCoreStyle.systemMessageTextConfig.color
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func setup(text: String?) {
        label.text = text
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        label.font = UltraCoreStyle.systemMessageTextConfig.font
        label.textColor = UltraCoreStyle.systemMessageTextConfig.color
    }
    
}
