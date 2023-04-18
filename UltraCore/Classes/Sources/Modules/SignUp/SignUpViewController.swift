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

    override func setupViews() {
        super.setupViews()
        self.logoImage.loadImage(by: self.config.logoUrl)
        self.view.addSubview(self.logoImage)
    }

    override func setupConstraints() {
        super.setupConstraints()
        self.logoImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(64)
        }
    }
}

extension SignUpViewController: SignUpViewInterface {
}