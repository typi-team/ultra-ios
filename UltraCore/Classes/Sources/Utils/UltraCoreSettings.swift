//
//  UltraCoreSettings.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//
import RxSwift
import UIKit

public class UltraCoreSettings {
    static func setupAppearance() {
        UIBarButtonItem.appearance().tintColor = .green500
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.defaultRegularHeadline]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
    }
    
}

public extension UltraCoreSettings {
     static func set(server config: ServerConfigurationProtocol?) {
         AppSettingsImpl.shared.serverConfig = config ?? ServerConfiguration()
     }

     static func entrySignUpViewController() -> UIViewController {
         setupAppearance()
         return SignUpWireframe().viewController
     }

     static func entryViewController() -> UIViewController {
         setupAppearance()
         return AppSettingsImpl.shared.appStore.isAuthed ? ConversationsWireframe().viewController : SignUpWireframe().viewController
     }

     static func entryConversationsViewController() -> UIViewController {
         setupAppearance()
         return ConversationsWireframe().viewController
     }

     static func update(sid token: String, with callback: @escaping (Error?) -> Void) {
         AppSettingsImpl.shared.appStore.ssid = token
         AppSettingsImpl.shared.update(ssid: token, callback: callback)
     }

     static func update(firebase token: String) {
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

     static func handleNotification(data: [AnyHashable: Any], callback: @escaping (UIViewController?) -> Void) {
         _ = AppSettingsImpl
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
}
