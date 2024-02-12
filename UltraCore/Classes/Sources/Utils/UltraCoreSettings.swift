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
    func availableToBlock(conversation: Any) -> Bool
}

public protocol UltraCoreSettingsDelegate: AnyObject {
    func emptyConversationView() -> UIView?
    func emptyConversationDetailView() -> UIView?
    func info(from id: String) -> IContactInfo?
    func token(callback: @escaping (Result<String, Error>) -> Void)
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

    static func updateSession(callback: @escaping (Error?) -> Void) {
        let tokenWork = Observable<String>.create { observer in
            Self.delegate?.token(callback: { result in
                switch result {
                case .success(let token):
                    observer.onNext(token)
                case .failure(let error):
                    observer.onError(error)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        }
        tokenWork
            .retry(when: { errors in
                return errors.enumerated().flatMap { (attempt, error) -> Observable<Int> in
                    let maxAttempts = 20
                    if attempt > maxAttempts {
                        return Observable.error(error)
                    }
                    return Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance)
                }
            })
            .subscribe { token in
                Self.update(sid: token, with: callback)
            }
            .disposed(by: disposeBag)
    }
    
    static func stopSession() {
        AppSettingsImpl.shared.updateRepository.stopSession()
    }

    static func update(sid token: String, timeOut: TimeInterval = 0,
                       with callback: @escaping (Error?) -> Void) {
        let shared = AppSettingsImpl.shared
        shared.appStore.ssid = token
        // TODO: Refactor this case into interactor or something like this object
        shared
            .authService
            .issueJwt(.with({
                $0.device = .ios
                $0.sessionID = token
                $0.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Ну указано"
            }), callOptions: .default())
            .response
            .whenComplete { result in
                switch result {
                case let .failure(error):
                    print("[ISSUE JWT] Error: \(error)")
                    callback(error)
                case let .success(value):
                    print("[ISSUE JWT] JWT: \(value.token)")
                    shared.appStore.store(token: value.token)
                    shared.appStore.store(userID: value.userID)
                    shared.updateRepository.setupSubscription()
                    shared.updateRepository.startPingPong()
                    shared.updateRepository.retreiveContactStatuses()
                    if shared.appStore.lastState == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + timeOut, execute: {
                            callback(nil)
                        })
                    } else {
                        callback(nil)
                    }
                }
            }
    }

    static func update(firebase token: String) {
        if AppSettingsImpl.shared.appStore.token == nil {
            PP.error("Don't call it without token")
            return
        }

        AppSettingsImpl.shared.deviceService.updateDevice(.with({
            $0.device = .ios
            $0.token = token
            $0.appVersion = AppSettingsImpl.shared.version
            $0.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Ну указано"
        }), callOptions: .default())
        .response
        .whenComplete({ result in
            switch result {
            case .success:
                PP.info("Data about device is updated")
            case let .failure(error):
                PP.error("Data about device is updated with \(error.localeError)")
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
        let shared = AppSettingsImpl.shared
        _ = ContactToConversationInteractor(contactDBService: shared.contactDBService,
                                            contactsService: shared.contactsService,
                                            integrateService: shared.integrateService)
        .executeSingle(params: contact)
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
