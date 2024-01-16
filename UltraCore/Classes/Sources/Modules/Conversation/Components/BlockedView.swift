//
//  BlockedView.swift
//  UltraCore
//
//  Created by Slam on 12/26/23.
//

import Foundation

protocol BlockViewDelegate: AnyObject {
    func unblock()
}

class BlockView: UIView {
    weak var delegate: BlockViewDelegate?

    private var style: MessageInputBarBlockedConfig? { UltraCoreStyle.mesageInputBarConfig?.blockedViewConfig }
    
    private lazy var divider: UIView = .init { $0.backgroundColor = style?.dividerColor.color }
    

    private lazy var blockView: UIButton = UIButton.init {
        $0.setTitle(ConversationStrings.unblock.localized.capitalized, for: .normal)
        $0.cornerRadius = kLowPadding
        $0.borderWidth = 0
        
        $0.addAction { [weak self] in
            self?.delegate?.unblock()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    private func setupView() {
        self.addSubview(blockView)
        self.addSubview(divider)

        self.divider.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        self.blockView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(kMediumPadding)
        }

        self.traitCollectionDidChange(UIScreen.main.traitCollection)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.backgroundColor = style?.background.color
        self.blockView.titleLabel?.font = style?.textConfig.font
        self.blockView.backgroundColor = style?.textBackgroundConfig.color
        self.blockView.setTitleColor(style?.textConfig.color, for: .normal)
        self.divider.backgroundColor = style?.dividerColor.color
    }
}
