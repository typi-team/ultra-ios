//
//  SignUpPresenter.swift
//  Pods
//
//  Created by Slam on 4/14/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation

final class SignUpPresenter {

    // MARK: - Private properties -

    private unowned let view: SignUpViewInterface
//    private let interactor: SignUpInteractorInterface
    private let wireframe: SignUpWireframeInterface

    // MARK: - Lifecycle -

    init(
        view: SignUpViewInterface,
//        interactor: SignUpInteractorInterface,
        wireframe: SignUpWireframeInterface
    ) {
        self.view = view
//        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: - Extensions -

extension SignUpPresenter: SignUpPresenterInterface {
}