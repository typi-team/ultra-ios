//
//  SignUpViewController.swift
//  Pods
//
//  Created by Slam on 4/14/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import SnapKit

final class SignUpViewController: BaseViewController<SignUpPresenterInterface> {

    fileprivate let logoImage = UIImageView({
        $0.contentMode = .scaleAspectFit
    })

    fileprivate let scrollView = UIScrollView({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    fileprivate lazy var nextButton = ElevatedButton({
        $0.setTitle("Продолжить", for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self,
                  let phone = self.phoneTextField.text,
                  let lastname = self.lastTextField.text,
                  let firstname = self.firstTextField.text,
                  !firstname.isEmpty, !lastname.isEmpty else { return }
            self.presenter?.login(lastName: lastname, firstname: firstname, phone: phone)
        }
    })

    fileprivate lazy var phoneTextField = PhoneNumberTextField({
        $0.backgroundColor = .white
        $0.font = .defaultRegularBody
        $0.placeholder = "Ваш номер телефона"
        $0.changesCallback = {[weak self] in
            self?.handleButtonEnabling()
        }
        $0.placeholderColor = .gray500
    })

    fileprivate lazy var firstTextField = PaddingTextField({
        $0.backgroundColor = .white
        $0.placeholder = "Ваше имя"
        $0.font = .defaultRegularBody
        $0.placeholderColor = .gray500
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        $0.addAction(for: .editingDidEndOnExit) {[weak self] in
            self?.lastTextField.becomeFirstResponder()
        }
    })

    fileprivate lazy var lastTextField = PaddingTextField({
        $0.returnKeyType = .done
        $0.backgroundColor = .white
        $0.font = .defaultRegularBody
        $0.placeholder = "Никнейм"
        $0.placeholderColor = .gray500
        $0.addAction(for: .editingDidEndOnExit) {[weak self] in
            self?.view.endEditing(true)
        }
    })
    
    fileprivate let stackView = UIStackView({
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    fileprivate let headlineText = RegularCallout({
        $0.numberOfLines = 0
        $0.textAlignment = .center
    })
    
    override func setupViews() {
        
        super.setupViews()
                
        self.navigationItem.title = ""
        
        self.handleKeyboardTransmission = true
        
        self.view.addSubview(scrollView)
        
        self.scrollView.addSubview(stackView)
        self.stackView.addArrangedSubview(logoImage)
        self.stackView.setCustomSpacing(kHeadlinePadding * 3, after: logoImage)
        self.stackView.addArrangedSubview(headlineText)
        self.stackView.setCustomSpacing(kHeadlinePadding, after: headlineText)
        
        self.stackView.addArrangedSubview(phoneTextField)
        self.stackView.setCustomSpacing(kLowPadding, after: phoneTextField)
        let phoneHint = RegularFootnote({ $0.text = "       " + "Например +77761595595" })
        self.stackView.addArrangedSubview(phoneHint)
        self.stackView.setCustomSpacing(kHeadlinePadding, after: phoneHint)
        
        self.stackView.addArrangedSubview(firstTextField)
        self.stackView.setCustomSpacing(kLowPadding, after: firstTextField)
        let firstHint = RegularFootnote({ $0.text = "       " + "Например Иван" })
        self.stackView.addArrangedSubview(firstHint)
        self.stackView.setCustomSpacing(kHeadlinePadding, after: firstHint)
        
        self.stackView.addArrangedSubview(lastTextField)
        self.stackView.setCustomSpacing(kLowPadding, after: lastTextField)
        let lastHint = RegularFootnote({ $0.text = "       " + "nickname_ff" })
        self.stackView.addArrangedSubview(lastHint)
        self.stackView.setCustomSpacing(kHeadlinePadding * 2, after: lastHint)
        
        let nextStack = UIStackView({
            $0.alignment = .center
            $0.distribution = .equalCentering
            
            $0.addArrangedSubview(UIView())
            $0.addArrangedSubview(nextButton)
            $0.addArrangedSubview(UIView())
        })
        self.stackView.addArrangedSubview(nextStack)
        self.stackView.setCustomSpacing(kHeadlinePadding * 2, after: nextStack)
        
    }

    override func setupConstraints() {
        super.setupConstraints()

        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kMediumPadding)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-kMediumPadding)
        }

        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        self.headlineText.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kHeadlinePadding)
            make.right.equalToSuperview().offset(-kHeadlinePadding)
        }
        
        self.logoImage.snp.makeConstraints { make in
            make.height.equalTo(kHeadlinePadding * 2)
            make.width.equalTo(168)
        }
        
        self.nextButton.snp.makeConstraints { make in
            make.height.equalTo(kLowPadding * 8)
            make.left.equalTo(kHeadlinePadding)
            make.right.equalTo(-kHeadlinePadding)
        }
    }
    
    override func textFieldDidChange(_ sender: UITextField) {
        self.handleButtonEnabling()
    }
    
    override func changedKeyboard(
        height: CGFloat,
        animationDuration: Double,
        animationOptions: UIView.AnimationOptions
    ) {
        self.scrollView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
        self.scrollView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: height, right: 0)
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func setupInitialData() {
        super.setupInitialData()
        self.handleButtonEnabling()
        self.logoImage.image = .named("ff_logo_text")
        self.headlineText.text = "Для регистрации в чат сервисе введите ваши данные"
        let userDef = UserDefaults.standard
        if let lastname = userDef.string(forKey: "last_name"),
           let firstname = userDef.string(forKey: "first_name"),
           let phone = userDef.string(forKey: "phone") {
            self.presenter?.login(lastName: lastname, firstname: firstname, phone: phone)
        }
    }
}

extension SignUpViewController: SignUpViewInterface {
    func open(view controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.navigationController?.viewControllers.removeAll(where: {$0 == self})
        })
    }
    
}

extension SignUpViewController {
    func handleButtonEnabling() {
        let isEnabled = (self.phoneTextField.text ?? "").count > 5 && (self.firstTextField.text ?? "").count > 1
        self.nextButton.isEnabled = isEnabled
        self.nextButton.backgroundColor = isEnabled ? .green600 : .green100
    }
}
