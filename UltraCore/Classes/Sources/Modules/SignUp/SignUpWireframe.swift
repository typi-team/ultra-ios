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
}

// MARK: - Extensions -
extension SignUpWireframe: SignUpWireframeInterface {
    func navigateToContacts() {
        let wireframe = ConversationsWireframe()
        let presentController = wireframe.viewController
        self.navigationController?.pushViewController(presentController, animated: true)
        self.navigationController?.viewControllers.removeAll(where: {$0 == self.viewController})
    }
}
 
