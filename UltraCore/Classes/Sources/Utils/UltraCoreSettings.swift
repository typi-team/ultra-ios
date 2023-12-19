//
//  UltraCoreSettings.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//
import RxSwift
import UIKit

public protocol UltraCoreFutureDelegate: AnyObject {
    func availableToContact() -> Bool
    func availableToLocation() -> Bool
    func availableToSendMoney() -> Bool
    func availableToRecordVoice() -> Bool
    func localize(for key: String) -> String?
    func availableToReport(message: Any) -> Bool
    
}

public protocol UltraCoreSettingsDelegate: AnyObject {
    func emptyConversationView() -> UIView?
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
    
}

public extension UltraCoreSettings {
    
    static func update(contacts: [IContactInfo]) throws {
        try ContactDBService.update(contacts: contacts)
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
         return SignUpWireframe().viewController
     }

     static func entryConversationsViewController() -> UIViewController {
         return ConversationsWireframe(appDelegate: UltraCoreSettings.delegate).viewController
     }

    static func update(sid token: String, timeOut: TimeInterval = 0,
                       with callback: @escaping (Error?) -> Void) {
         AppSettingsImpl.shared.appStore.ssid = token
         AppSettingsImpl.shared.update(ssid: token, callback: { error in

             if error == nil {
                 AppSettingsImpl.shared.updateRepository.setupSubscription()
             }
             
             if AppSettingsImpl.shared.appStore.lastState == 0 {
                 DispatchQueue.main.asyncAfter(deadline: .now() + timeOut, execute: {
                     callback(error)
                 })
             } else {
                 callback(error)
             }
         })
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
    
    static func conversation(by contact: IContact, callback: @escaping (UIViewController?) -> Void){
        _ = AppSettingsImpl.shared.contactToConversationInteractor.executeSingle(params: contact)
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
    
    static func logout() {
        AppSettingsImpl.shared.logout()
    }
}
