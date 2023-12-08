//
//  DeleteMessageController.swift
//  UltraCore
//
//  Created by Slam on 11/15/23.
//


import UIKit

class ActionsViewController: BaseViewController<String> {
    
    var headlineText : String? {
        didSet {
            self.headlineLabel.text = headlineText
        }
    }
    
    var regularText : String? {
        didSet {
            self.regularLabel.text = regularText
        }
    }

    fileprivate let headlineLabel: HeadlineBody = .init({
        $0.textAlignment = .left
    })
    
    fileprivate let regularLabel: RegularBody = .init()
    
    var additionalButtons: [ElevatedButton] = []
    
    fileprivate lazy var cancelButton: ElevatedButton = .init({
        $0.titleLabel?.numberOfLines = 0
        $0.backgroundColor = .white
        $0.setTitleColor(UltraCoreStyle.elevatedButtonTint?.color, for: .normal)
        $0.setTitle(EditActionStrings.cancel.localized.capitalized, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }
    })

    fileprivate lazy var stackView: UIStackView = .init {[weak self] stack in
        guard let `self` = self else { return }
        stack.axis = .vertical
        stack.spacing = kLowPadding
        stack.addArrangedSubview(headlineLabel)
        stack.setCustomSpacing(kHeadlinePadding, after: headlineLabel)
        stack.addArrangedSubview(regularLabel)
        stack.setCustomSpacing(kHeadlinePadding, after: regularLabel)
        
        self.additionalButtons.forEach( { button in
            stack.addArrangedSubview(button)
            stack.setCustomSpacing(kLowPadding, after: button)
        })
        
        stack.addArrangedSubview(cancelButton)
        stack.setCustomSpacing(kHeadlinePadding, after: cancelButton)
    }
    
    override func setupViews() {
        super.setupViews()
        if(self.regularText == nil) {
            self.regularLabel.removeFromSuperview()
        }
        self.view.addSubview(stackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kHeadlinePadding + kMediumPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-kLowPadding)
        }
        ([cancelButton] + additionalButtons) .forEach( {
            $0.snp.makeConstraints({
                $0.height.equalTo(56)
            })
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
//        self._buildPaymentDescription()
    }
}
