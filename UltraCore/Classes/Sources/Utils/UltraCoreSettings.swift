//
//  UltraCoreSettings.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//

import UIKit

func setupAppearance() {
    UIBarButtonItem.appearance().tintColor = .green500
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.defaultRegularHeadline]
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: UIControlState.highlighted)
}

public func entrySignUpViewController()->  UIViewController {
    setupAppearance()
    return SignUpWireframe().viewController
}

public func entryViewController()->  UIViewController {
    setupAppearance()
    return AppSettingsImpl.shared.appStore.isAuthed ? ConversationsWireframe().viewController : SignUpWireframe().viewController
}

public func entryConversationsViewController()->  UIViewController {
    setupAppearance()
    return ConversationsWireframe().viewController
}


public func update(sid token: String, with callback: @escaping(Error?) -> Void) {
    AppSettingsImpl.shared.appStore.ssid = token
    AppSettingsImpl.shared.update(ssid: token, callback: callback)
}
