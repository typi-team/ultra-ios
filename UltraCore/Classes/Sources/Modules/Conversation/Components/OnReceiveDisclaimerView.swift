//
//  OnReceiveDisclaimerView.swift
//  UltraCore
//
//  Created by Typi on 11.03.2024.
//

import UIKit

final class OnReceiveDisclaimerView: UIView {
    private enum Constants {
        static let avatarSize: CGFloat = 80
    }
    private let disclaimerView = DisclaimerView()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UltraCoreStyle.disclaimerStyle.contactTextConfig.font
        label.textColor = UltraCoreStyle.disclaimerStyle.contactTextConfig.color
        label.textAlignment = .center
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UltraCoreStyle.disclaimerStyle.contactDescriptionConfig.font
        label.textColor = UltraCoreStyle.disclaimerStyle.contactDescriptionConfig.color
        label.textAlignment = .center
        return label
    }()
    private let avatarImageView = UIImageView {
        $0.layer.cornerRadius = Constants.avatarSize / 2
        $0.clipsToBounds = true
    }
    private lazy var labelStack = UIStackView {
        $0.axis = .vertical
        $0.addArrangedSubview(nameLabel)
        $0.addArrangedSubview(descriptionLabel)
    }
    
    weak var delegate: DisclaimerViewDelegate? {
        didSet {
            disclaimerView.delegate = delegate
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        [disclaimerView, labelStack, avatarImageView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        avatarImageView.snp.makeConstraints {
            $0.top.equalTo(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Constants.avatarSize)
        }
        labelStack.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(12)
            $0.leading.equalTo(16)
            $0.trailing.equalTo(-16)
        }
        disclaimerView.snp.makeConstraints {
            $0.top.equalTo(labelStack.snp.bottom).offset(-8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(-16)
        }
    }
    
    func update(with contact: ContactDisplayable?) {
        nameLabel.text = contact?.displaName
        descriptionLabel.text = UltraCoreSettings.delegate?.disclaimerDescriptionFor(contact: contact?.phone ?? "")
        avatarImageView.image = contact?.image ?? UltraCoreStyle.disclaimerStyle.logoPlaceholder.image
    }
}

extension OnReceiveDisclaimerView {
    static func show(on view: UIView, contact: ContactDisplayable?, delegate: DisclaimerViewDelegate) {
        guard !view.subviews.contains(where: { $0.tag == 99 }) else {
            return
        }
        let container = UIView()
        container.tag = 99
        container.layer.cornerRadius = 16
        container.backgroundColor = UltraCoreStyle.disclaimerStyle.backgroundColor.color
        let disclaimer = OnReceiveDisclaimerView()
        disclaimer.update(with: contact)
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
