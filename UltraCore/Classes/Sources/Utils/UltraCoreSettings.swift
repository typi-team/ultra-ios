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
    func availableToCall() -> Bool
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
    func callImage() -> UIImage?
    func disclaimerDescriptionFor(contact: String) -> String
    func tokenUpdated()
    func unreadMessagesUpdated(count: Int)
    func provideTransferScreen(for userID: String, viewController: UIViewController, transferCallback: MoneyCallback)
}

extension UltraCoreSettingsDelegate {
    func tokenUpdated() {}
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
    
    static func updateOrCreate(contacts: [IContactInfo]) throws {
        let contactsDBService = AppSettingsImpl.shared.contactDBService
        let contactByUserIdInteractor = ContactByUserIdInteractor(delegate: nil, contactsService: AppSettingsImpl.shared.contactsService)

        Observable.from(contacts)
            .flatMap { contactByUserIdInteractor.executeSingle(params: $0.identifier).retry(2) }
            .flatMap({ contactsDBService.save(contact: $0) })
            .subscribe(
                onNext: {
                    PP.info("Контакты успешно сохранены")
                },
                onError: { error in
                    PP.error("Ошибка при сохранении контакта: \(error)")
                },
                onCompleted: {
                    PP.info("Все контакты были обработаны и сохранены")
                }
            )
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
        PP.debug("Attempt to update session token")
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
                    PP.error("Error on JWT issue - \(error.localeError)")
                    callback(error)
                case let .success(value):
                    PP.debug("Successfully updated session token")
                    shared.appStore.store(token: value.token)
                    shared.appStore.store(userID: value.userID)
                    shared.updateRepository.setupSubscription()
                    shared.updateRepository.startPingPong()
                    shared.updateRepository.retreiveContactStatuses()
                    delegate?.tokenUpdated()
                    if shared.appStore.lastState == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + timeOut, execute: {
                            callback(nil)
                            UnreadMessagesService.updateUnreadMessagesCount()
                        })
                    } else {
                        callback(nil)
                        UnreadMessagesService.updateUnreadMessagesCount()
                    }
                }
            }
    }

    static func update(firebase token: String, voipToken: String?) {
        if AppSettingsImpl.shared.appStore.token == nil {
            PP.error("Error on updateDevice; No token found")
            return
        }
        
        AppSettingsImpl.shared.deviceService.updateDevice(.with({
            $0.device = .ios
            $0.token = token
            $0.appVersion = AppSettingsImpl.shared.version
            $0.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Ну указано"
            if let voipToken {
                $0.voipPushToken = voipToken
            }
        }), callOptions: .default())
        .response
        .whenComplete({ result in
            switch result {
            case .success:
                PP.info("Data about device is updated")
            case let .failure(error):
                PP.error("Error on updateDevice \(error.localeError)")
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
    
    static func lastSeenOfContacts(callback: @escaping (([[ContactInfo: Any]]) -> Void)) {
        _ = AppSettingsImpl.shared
            .contactDBService
            .contacts()
            .subscribe { contacts in
                callback(contacts
                    .map({ [ContactInfo.id: $0.phone,
                            ContactInfo.isOnline: $0.status.isOnline,
                            ContactInfo.atLastSeen: $0.status.lastSeen,
                            ContactInfo.displayableDate: $0.status.displayText] }))
            }
    }

    static func logout() {
        AppSettingsImpl.shared.logout()
    }
}

public enum ContactInfo {
    case isOnline, atLastSeen, id, displayableDate
}
