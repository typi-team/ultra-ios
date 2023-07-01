//
//  UltraCoreSettings.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//
import RxSwift
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

public func update(firebase token: String) {
    AppSettingsImpl.shared.deviceService.updateDevice(.with({
        $0.device = .ios
        $0.token = token
        $0.appVersion = AppSettingsImpl.shared.version
        $0.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Ну указано"
    }), callOptions: .default())
        .response
        .whenComplete({ result in
            switch result {
            case let .success(response):
                print(response)
            case let .failure(error):
                print(error)
            }
        })
}

public func handleNotification(data: [AnyHashable: Any], callback:@escaping (UIViewController?) -> Void) {
    AppSettingsImpl
        .shared
        .superMessageSaverInteractor
        .executeSingle(params: data)
        .subscribe(on: MainScheduler.instance)
        .observe(on: MainScheduler.instance)
        .subscribe(onSuccess: { conversation in
            if let conversation = conversation {
                callback(ConversationWireframe(with: conversation).viewController)
            } else {
                callback(nil)
            }

        }, onFailure: { error in
            callback(nil)
        })
}


