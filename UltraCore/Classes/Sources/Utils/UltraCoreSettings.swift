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
    var activeConversationID: String? { get set }
    func emptyConversationView(isSupport: Bool) -> UIView?
    func emptyConversationDetailView(isManager: Bool) -> UIView?
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
    func unreadAllMessagesUpdated(count: Int)
    func unreadSupportMessagesUpdated(count: Int)
    func unreadNonSupportMessagesUpdated(count: Int)
    func provideTransferScreen(
        for userID: String,
        viewController: UIViewController,
        transferCallback: @escaping MoneyCallback
    )
    func realmEncryptionKeyData() -> Data?
    func didTapTransactionCell(transactionID: String, viewController: UIViewController)
    func getSupportChatsAndManagers(callBack: @escaping (([String: Any]) -> Void))
    func getMessageMeta() -> Dictionary<String, String>
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
    
    private static var isUpdatingSession: Bool = false
    private static let disposeBag = DisposeBag()
    
    static var isConnected: Bool {
        AppSettingsImpl.shared.updateRepository.isConnectedToListenStream
    }

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
                onNext: { _ in
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

    static func entryConversationsViewController(isSupport: Bool) -> UIViewController {
        return ConversationsWireframe(
            appDelegate: UltraCoreSettings.delegate,
            isSupport: isSupport
        ).viewController
    }

    static func updateSession(callback: @escaping (Error?) -> Void) {
        guard !isUpdatingSession else {
            return
        }
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
        isUpdatingSession = true
        tokenWork
            .retry(when: { errors in
                return errors.enumerated().flatMap { (attempt, error) -> Observable<Int> in
                    let maxAttempts = 20
                    if attempt > maxAttempts {
                        isUpdatingSession = false
                        return Observable.error(error)
                    }
                    return Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance)
                }
            })
            .subscribe { token in
                isUpdatingSession = false
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
                            AppSettingsImpl.shared.updateRepository.triggerUnreadUpdate()
                        })
                    } else {
                        callback(nil)
                        AppSettingsImpl.shared.updateRepository.triggerUnreadUpdate()
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
                    callback(ConversationWireframe(with: conversation, isPersonalManager: false).viewController)
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
                callback(ConversationWireframe(with: conversation, isPersonalManager: false).viewController)
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
    
    static func getSupportStatus(for chatID: String, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        let timer = Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
        let offices = AppSettingsImpl.shared.updateRepository.supportOfficesObservable.compactMap { $0 }.take(until: timer)
        let chat = AppSettingsImpl.shared.conversationDBService.conversation(by: chatID).asObservable()
        var result: Result<Bool, Error> = .success(false)
        chat
            .flatMap { conversation -> Observable<Bool> in
                guard let conversation = conversation else {
                    return Observable.error(NSError(domain: "No conversation Found", code: -1))
                }
                
                if conversation.chatType == .support {
                    return Observable.just(true)
                } else if conversation.chatType == .peerToPeer {
                    return Observable.zip(offices, Observable.just(conversation))
                        .map { (officesResponse, conversation) in
                            guard let peer = conversation.peers.first else {
                                return false
                            }
                            let isManager = officesResponse.personalManagers
                                .map { String($0.userId) }
                                .contains(where: { $0 == peer.phone })
                            return isManager
                        }
                } else {
                    return Observable.just(false)
                }
            }
            .take(1)
            .subscribe { isSupport in
                result = .success(isSupport)
            } onError: { error in
                result = .failure(error)
            } onCompleted: {
                completion(result)
            }
            .disposed(by: Self.disposeBag)
    }

    static func logout() {
        AppSettingsImpl.shared.logout()
    }
}

public enum ContactInfo {
    case isOnline, atLastSeen, id, displayableDate
}
