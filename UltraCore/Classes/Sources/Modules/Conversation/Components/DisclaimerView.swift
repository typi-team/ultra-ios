//
//  DisclaimerView.swift
//  UltraCore
//
//  Created by Typi on 06.03.2024.
//

import UIKit

protocol DisclaimerViewDelegate: AnyObject {
    func disclaimerDidTapClose()
    func disclaimerDidTapAgree()
}

final class DisclaimerView: UIView {
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(
            UIImage(color: UltraCoreStyle.disclaimerStyle.closeButtonBackgroundColor.color),
            for: .normal
        )
        button.setBackgroundImage(
            UIImage(color: UltraCoreStyle.disclaimerStyle.closeButtonBackgroundColor.color.withAlphaComponent(0.5)),
            for: .normal
        )
        button.clipsToBounds = true
        button.backgroundColor = UltraCoreStyle.disclaimerStyle.closeButtonBackgroundColor.color
        button.setTitle(ConversationStrings.disclaimerClose.localized, for: .normal)
        button.setTitleColor(UltraCoreStyle.disclaimerStyle.closeButtontTextConfig.color, for: .normal)
        button.layer.cornerRadius = 6
        button.titleLabel?.font = UltraCoreStyle.disclaimerStyle.closeButtontTextConfig.font
        return button
    }()
    private let agreeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(
            UIImage(color: UltraCoreStyle.disclaimerStyle.agreeButtonBackgroundColor.color), 
            for: .normal
        )
        button.setBackgroundImage(
            UIImage(color: UltraCoreStyle.disclaimerStyle.agreeButtonBackgroundColor.color.withAlphaComponent(0.5)),
            for: .normal
        )
        button.clipsToBounds = true
        button.setTitle(ConversationStrings.disclaimerAgree.localized, for: .normal)
        button.setTitleColor(UltraCoreStyle.disclaimerStyle.agreeButtonTextConfig.color, for: .normal)
        button.layer.cornerRadius = 6
        button.titleLabel?.font = UltraCoreStyle.disclaimerStyle.agreeButtonTextConfig.font
        return button
    }()
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [closeButton, agreeButton])
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = UltraCoreStyle.disclaimerStyle.warningTextConfig.font
        label.textColor = UltraCoreStyle.disclaimerStyle.warningTextConfig.color
        label.numberOfLines = 0
        label.text = ConversationStrings.disclaimer.localized
        return label
    }()
    private let disclaimerLogo = UIImageView(image: UIImage.fromAssets("conversation_warning"))
    private lazy var disclaimerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [disclaimerLogo, disclaimerLabel])
        stack.spacing = 16
        return stack
    }()
    
    weak var delegate: DisclaimerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        disclaimerLogo.snp.makeConstraints { $0.size.equalTo(36) }
        agreeButton.snp.makeConstraints { $0.height.equalTo(48) }
        agreeButton.addAction { [weak self] in
            self?.delegate?.disclaimerDidTapAgree()
        }
        closeButton.snp.makeConstraints { $0.height.equalTo(48) }
        closeButton.addAction { [weak self] in
            self?.delegate?.disclaimerDidTapClose()
        }
        [buttonsStack, disclaimerStack].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        disclaimerStack.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.leading.equalTo(16)
            $0.trailing.equalTo(-16)
        }
        buttonsStack.snp.makeConstraints {
            $0.top.equalTo(disclaimerStack.snp.bottom).offset(12)
            $0.leading.equalTo(16)
            $0.trailing.equalTo(-16)
            $0.bottom.equalTo(-16)
        }
    }
    
}

extension DisclaimerView {
    static func show(on view: UIView, delegate: DisclaimerViewDelegate) {
        guard !view.subviews.contains(where: { $0.tag == 99 }) else {
            return
        }
        let container = UIView()
        container.tag = 99
        container.layer.cornerRadius = 16
        container.backgroundColor = UltraCoreStyle.disclaimerStyle.backgroundColor.color
        let disclaimer = DisclaimerView()
        disclaimer.delegate = delegate
        disclaimer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(disclaimer)
        view.addSubview(container)
        disclaimer.snp.makeConstraints { $0.edges.equalToSuperview() }
        container.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.leading.equalTo(16)
            $0.trailing.equalTo(-16)
        }
    }
    
    static func hide(from view: UIView) {
        guard let disclaimer = view.subviews.first(where: { $0.tag == 99 }) else {
            return
        }
        disclaimer.removeFromSuperview()
    }
}
