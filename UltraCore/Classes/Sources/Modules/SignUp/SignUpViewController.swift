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

struct SignUpConfigs {
    let logoUrl = "https://longterminvestments.ru/wp-content/uploads/2019/11/freedom-logo1.png"
}

final class SignUpViewController: BaseViewController<SignUpPresenterInterface> {
    fileprivate let config = SignUpConfigs()

    fileprivate let logoImage = UIImageView()

    fileprivate let scrollView = UIScrollView({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    fileprivate lazy var nextButton = ElevatedButton({
        $0.setTitle("Продолжить", for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self,
            let phone = self.phoneTextField.text,
            let firstname = self.firstTextField.text,
                let lastname = self.lastTextField.text else { return }
            self.presenter?.login(lastName: lastname, firstname: firstname, phone: phone)
        }
    })

    fileprivate let phoneTextField = PhoneNumberTextField({
        $0.backgroundColor = .white
        $0.font = .defaultRegularBody
        $0.placeholder = "Ваш номер телефона"
    })

    fileprivate lazy var firstTextField = CustomTextField({
        $0.backgroundColor = .white
        $0.font = .defaultRegularBody
        $0.placeholder = "Ваше имя"
        $0.addAction(for: .editingDidEndOnExit) {[weak self] in
            self?.lastTextField.becomeFirstResponder()
        }
    })

    fileprivate lazy var lastTextField = CustomTextField({
        $0.returnKeyType = .done
        $0.backgroundColor = .white
        $0.font = .defaultRegularBody
        $0.placeholder = "Ваша Фамилия"
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
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(stackView)
        self.stackView.addArrangedSubview(logoImage)
        self.stackView.setCustomSpacing(kHeadlinePadding * 3, after: logoImage)
        self.stackView.addArrangedSubview(headlineText)
        self.stackView.setCustomSpacing(kHeadlinePadding, after: headlineText)
        
        self.stackView.addArrangedSubview(phoneTextField)
        self.stackView.setCustomSpacing(kLowPadding, after: phoneTextField)
        let phoneHint = RegularFootnote({ $0.text = "    " + "Например +77761595595" })
        self.stackView.addArrangedSubview(phoneHint)
        self.stackView.setCustomSpacing(kHeadlinePadding, after: phoneHint)
        
        self.stackView.addArrangedSubview(firstTextField)
        self.stackView.setCustomSpacing(kLowPadding, after: firstTextField)
        let firstHint = RegularFootnote({ $0.text = "    " + "Например Иван" })
        self.stackView.addArrangedSubview(firstHint)
        self.stackView.setCustomSpacing(kHeadlinePadding, after: firstHint)
        
        self.stackView.addArrangedSubview(lastTextField)
        self.stackView.setCustomSpacing(kLowPadding, after: lastTextField)
        let lastHint = RegularFootnote({ $0.text = "    " + "Например Иванов" })
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
        
        self.logoImage.snp.makeConstraints { make in
            make.height.equalTo(kHeadlinePadding * 2)
        }
        
        self.nextButton.snp.makeConstraints { make in
            make.height.equalTo(kMediumPadding * 3)
            make.left.equalTo(kHeadlinePadding)
            make.right.equalTo(-kHeadlinePadding)
        }
    }
    
    override func setupInitialData() {
        super.setupInitialData()
        self.logoImage.loadImage(by: self.config.logoUrl)
        self.headlineText.text = "Для регистрации в чат сервисе введите ваши данные"
    }
    
    override func debugInitialData() {
        super.debugInitialData()
        self.presenter?.login(lastName: "Test", firstname: "Aidana", phone: "+77756043111")
    }
}

extension SignUpViewController: SignUpViewInterface {
}
