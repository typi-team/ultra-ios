//
//  MoneyTransferViewController.swift
//  Pods
//
//  Created by Slam on 8/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class MoneyTransferViewController: BaseViewController<MoneyTransferPresenter> {

    fileprivate let headlineLabel: HeadlineBody = .init({
        $0.textAlignment = .left
        $0.text = ConversationStrings.insideTheBank.localized
    })

    fileprivate let titleLabel: RegularFootnote = .init({
        $0.text = ConversationStrings.writeOffTheCard.localized
    })
    
    fileprivate lazy var cardButton: CardButton = .init()
    
    fileprivate lazy var sunInfoLabel: RegularFootnote = .init({
        $0.text = ConversationStrings.transferAmount.localized
    })
    
    fileprivate lazy var continButton: ElevatedButton = .init({

        $0.setTitle(ConversationStrings.send.localized, for: .normal)
        $0.backgroundColor = UltraCoreAppearance.buttonTint
        $0.addAction {[weak self] in
            self?.view.endEditing(true)
            guard let `self` = self,
                    let text = self.summTextField.text,
                  let value = Double(text) else { return }
            self.presenter?.send(money: value, callback: {[weak self] in
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            })
        }
    })
    
    fileprivate lazy var summTextField: UITextField = .init({
        $0.placeholder = "0.0"
        $0.keyboardType = .numberPad
        $0.addAction(for: .editingChanged, { [weak self] in
            guard let `self` = self,
                  let summValue = self.summTextField.text,
                  let summ = Int(summValue) else { return }
            self.continButton.isEnabled = summ > 0
        })
        $0.rightViewMode = .always
        $0.rightView = UIButton.init({
            $0.setImage(.named("conversation_erase"), for: .normal)
            $0.addAction {[weak self] in
                guard let `self` = self else { return }
                self.summTextField.text = ""
            }
        })
    })
    
    fileprivate let greenDivider: UIView = .init{
        $0.backgroundColor = .green500
    }

    fileprivate lazy var stackView: UIStackView = .init {
        $0.axis = .vertical
        $0.spacing = kLowPadding
        $0.addArrangedSubview(headlineLabel)
        $0.setCustomSpacing(kHeadlinePadding, after: headlineLabel)
        $0.addArrangedSubview(cardButton)
        $0.setCustomSpacing(kHeadlinePadding * 2, after: cardButton)
        $0.addArrangedSubview(sunInfoLabel)
        $0.addArrangedSubview(summTextField)
        $0.addArrangedSubview(greenDivider)
        $0.setCustomSpacing(kHeadlinePadding * 2, after: greenDivider)
        $0.addArrangedSubview(continButton)
        $0.setCustomSpacing(kHeadlinePadding * 2, after: continButton)
    }
    
    override func setupViews() {
        super.setupViews()
        self.handleKeyboardTransmission = true
        self.view.addSubview(stackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kHeadlinePadding + kMediumPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
        }
        
        self.greenDivider.snp.makeConstraints { make in
            make.height.equalTo(2)
        }
        
        self.continButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    override func setupInitialData() {
        self.summTextField.becomeFirstResponder()
    }
    
    override func changedKeyboard(
        frame: CGRect,
        animationDuration: Double,
        animationOptions: UIView.AnimationOptions
    ) {
        let keyboardHeight = UIScreen.main.bounds.height - frame.origin.y
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            self.view.frame.origin.y = keyboardHeight >= 0 ? UIScreen.main.bounds.height - self.view.frame.height - keyboardHeight : 0
        }
    }
}

// MARK: - Extensions -

extension MoneyTransferViewController: MoneyTransferViewInterface {
}
