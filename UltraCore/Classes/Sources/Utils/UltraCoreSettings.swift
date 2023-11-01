//
//  UltraCoreSettings.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//
import RxSwift
import UIKit

public protocol UltraCoreFutureDelegate: AnyObject {
    func availableToSendMoney() -> Bool
}

public protocol UltraCoreSettingsDelegate: AnyObject {
    func info(from id: String) -> IContactInfo?
    func serverConfig() -> ServerConfigurationProtocol?
    func contactViewController(contact id: String) -> UIViewController?
    func moneyViewController(callback: @escaping MoneyCallback) -> UIViewController?
    func contactsViewController(contactsCallback: @escaping ContactsCallback,
                                openConverationCallback: @escaping UserIDCallback) -> UIViewController?
}

private let disposeBag = DisposeBag()
private let interactor = ContactsBookInteractor()

public class UltraCoreSettings {
    
    public static weak var delegate: UltraCoreSettingsDelegate?
    public static weak var futureDelegate: UltraCoreFutureDelegate?
    
    static func setupAppearance() {
        UIBarButtonItem.appearance().tintColor = .green500
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.defaultRegularHeadline]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
    }
}

public extension UltraCoreSettings {
    
    static func update(contacts: [IContactInfo]) throws {
        try AppSettingsImpl.shared.contactDBService.update(contacts: contacts)
    }
    
    static func allContactsIn(callback: @escaping ([IContactInfo]) -> Void) {
        interactor
            .executeSingle(params: ())
            .subscribe(onSuccess: { response in
                switch response {
                case let .authorized(contacts: contacts):
                    callback(contacts)
                case .denied: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    static func printAllLocalizableStrings() {
        print("================= Localizable =======================")
        print(CallStrings.allCases.map({"\"\($0.descrition)\" = \"\($0.localized)\";"}).joined(separator: "\n"))
        print(ConversationsStrings.allCases.map({"\"\($0.descrition)\" = \"\($0.localized)\";"}).joined(separator: "\n"))
        print(ContactsStrings.allCases.map({"\"\($0.descrition)\" = \"\($0.localized)\";"}).joined(separator: "\n"))
        print(ConversationStrings.allCases.map({"\"\($0.descrition)\" = \"\($0.localized)\";"}).joined(separator: "\n"))
        print(MessageStrings.allCases.map({"\"\($0.descrition)\" = \"\($0.localized)\";"}).joined(separator: "\n"))
        print("=================             =======================")
    }

     static func entrySignUpViewController() -> UIViewController {
         setupAppearance()
         return SignUpWireframe().viewController
     }

     static func entryConversationsViewController() -> UIViewController {
         setupAppearance()
         return ConversationsWireframe(appDelegate: UltraCoreSettings.delegate).viewController
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
