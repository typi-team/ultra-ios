//
//  SignUpWireframe.swift
//  Pods
//
//  Created by Slam on 4/14/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class SignUpWireframe: BaseWireframe<SignUpViewController> {
    
    @discardableResult
    init() {
        let moduleViewController = SignUpViewController({
            $0.modalPresentationStyle = .fullScreen
        })
        super.init(viewController: moduleViewController)
        let userIdInteractor = UserIdInteractorImpl.init(authService: appSettings.authService)
        let jwtInteractor = JWTTokenInteractorImpl.init(authService: appSettings.authService)
        let presenter = SignUpPresenter(view: moduleViewController,
                                        appSettingsStore: AppSettingsStoreImpl(),
                                        wireframe: self, jwtInteractor: jwtInteractor, userIdInteractor: userIdInteractor)
        moduleViewController.presenter = presenter
        
    }
    
    func start(presentation controller: UIViewController) {
        let navigation  = UINavigationController.init(rootViewController: self.viewController)
        navigation.modalPresentationStyle = .fullScreen
        controller.present(navigation, animated: true)
    }
}

// MARK: - Extensions -
extension SignUpWireframe: SignUpWireframeInterface {
    func navigateToContacts() {
        self.navigationController?.pushWireframe(ConversationsWireframe())
    }
}
