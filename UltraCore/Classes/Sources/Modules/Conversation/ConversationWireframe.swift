//
//  ConversationWireframe.swift
//  Pods
//
//  Created by Slam on 4/25/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class ConversationWireframe: BaseWireframe<ConversationViewController> {

    // MARK: - Private properties -

    // MARK: - Module setup -

    init() {
        let moduleViewController = ConversationViewController()
        super.init(viewController: moduleViewController)

        let presenter = ConversationPresenter(view: moduleViewController, wireframe: self)
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension ConversationWireframe: ConversationWireframeInterface {
}
