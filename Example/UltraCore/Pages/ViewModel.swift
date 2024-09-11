//
//  ViewModel.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//
import UltraCore
import Foundation
import FirebaseMessaging
import RxSwift

struct UserResponse: Codable {
    let sid: String
    let sidExpire: Int
    let firstname: String
    let lastname: String
    let phone: String
    
    private enum CodingKeys: String, CodingKey {
        case sid
        case sidExpire = "sid_expire"
        case firstname
        case lastname
        case phone
    }
}

class ViewModel {
    fileprivate var timerUpdate: Timer?
    private let disposeBag = DisposeBag()
    private let userDefaults: UserDefaults? = UserDefaults(suiteName: "com.ultaCore.messenger")
    
    var activeConversationID: String? {
        didSet {
            (UIApplication.shared.delegate as? AppDelegate)?.activeConversationID = activeConversationID
        }
    }
    
    var onUnreadMessagesUpdated: ((Int) -> Void)?

    func viewDidLoad() {
        UltraCoreSettings.delegate = self
        UltraCoreSettings.futureDelegate = self
        PP.logLevel = .verbose
    }
    
    var phone: String? {UserDefaults.standard.string(forKey: "phone") }
    
    func setupSID(callback: @escaping (Error?) -> Void) {
        guard UserDefaults.standard.string(forKey: "phone") != nil else {
            return callback(NSError.init(domain: "no saved account", code: 101))
        }
        UltraCoreSettings.updateSession(callback: callback)
    }
    
    func didRegisterForRemoteNotifications() {
        guard let url = URL(string: "https://ultra-dev.typi.team/mock/v1/device"),
              let firebaseToken = Messaging.messaging().fcmToken,
              let sidToken = UserDefaults.standard.string(forKey: "K_SID"),
              let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let jsonData = try? JSONSerialization.data(withJSONObject: [
                  "app_version": appVersion,
                  "token": firebaseToken,
                  "device_id": UltraCoreSettings.deviceID,
                  "platform": "IOS",
                  "voip_push_token": UltraVoIPManager.shared.token ?? ""
              ]) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.setValue(sidToken, forHTTPHeaderField: "SID")
        PP.debug("SID \(sidToken) voip - \(UltraVoIPManager.shared.token)")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in }
        task.resume()
    }
    
}

extension ViewModel: UltraCoreFutureDelegate {
    func availableToBlock(conversation: Any) -> Bool {
        true 
    }
    
    func availableToRecordVoice() -> Bool {
        true
    }
    
    func availableToReport(message: Any) -> Bool {
        true
    }
    
    func availableToCall() -> Bool {
        true
    }
    
    func localize(for key: String) -> String? {
        nil
    }
    
    func availableToSendMoney() -> Bool {
        return true
    }
}

extension ViewModel: UltraCoreSettingsDelegate {

    func emptyConversationDetailView(isManager: Bool) -> UIView? {
        return nil
    }

    func provideTransferScreen(
        for userID: String,
        viewController: UIViewController,
        transferCallback: @escaping (UltraCore.MoneyTransfer) -> Void,
        retryCallback: @escaping (() -> Void)
    ) {

    }
    
    func unreadAllMessagesUpdated(count: Int) {
        onUnreadMessagesUpdated?(count)
        switch UIApplication.shared.applicationState {
            case .active:
                UIApplication.shared.applicationIconBadgeNumber = count
            default:
                break
        }
    }
    
    func unreadSupportMessagesUpdated(count: Int) {
        
    }
    
    func unreadNonSupportMessagesUpdated(count: Int) {
        
    }
    
    
    func token(callback: @escaping (Result<String, Error>) -> Void) {
        let userDef = UserDefaults.standard
        guard let lastname = userDef.string(forKey: "last_name"),
              let firstname = userDef.string(forKey: "first_name"),
              let phone = userDef.string(forKey: "phone") else {
            return callback(.failure(NSError.init(domain: "no saved account", code: 101)))
        }

        guard let url = URL(string: "https://ultra-dev.typi.team/mock/v1/auth"),
              let jsonData = try? JSONSerialization.data(withJSONObject: [
                  "phone": phone,
                  "lastname": lastname,
                  "firstname": firstname,
                  "nickname": firstname,
              ]) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
                
        URLSession.shared.rx.data(request: request)
            .map {
                try JSONDecoder().decode(UserResponse.self, from: $0)
            }
            .do(onNext: { [weak self] userResponse in
                UserDefaults.standard.set(userResponse.sid, forKey: "K_SID")
                self?.didRegisterForRemoteNotifications()
            })
            .subscribe { userResponse in
                callback(.success(userResponse.sid))
            } onError: { error in
                callback(.failure(error))
            }
            .disposed(by: disposeBag)
    }
    
    func tokenUpdated() {
        didRegisterForRemoteNotifications()
    }

    func emptyConversationView(isSupport: Bool) -> UIView? {
        return nil
    }
    
    func emptyConversationDetailView() -> UIView? {
        return nil
    }
    
    func info(from id: String) -> UltraCore.IContactInfo? {
        return nil
    }
    
    func contactsViewController(contactsCallback: @escaping ContactsCallback, openConverationCallback: @escaping UserIDCallback) -> UIViewController? {
        return nil
    }

    func serverConfig() -> ServerConfigurationProtocol? {
        return ServerConfigImpl()
    }
    
    func moneyViewController(callback: @escaping MoneyCallback) -> UIViewController? {
        return nil
    }
    
    func contactViewController(contact id: String) -> UIViewController? {
        return nil
    }
    
    func availableToContact() -> Bool {
        return true
    }
    
    func availableToLocation() -> Bool {
        return true
    }
    
    func callImage() -> UIImage? {
        return UIImage(named: "tradernet_call_icon")
    }
    
    func disclaimerDescriptionFor(contact: String) -> String {
        return NSLocalizedString("conversation.disclaimerDescription", comment: "")
    }
    
    func realmEncryptionKeyData() -> Data? {
        if let key = UserDefaults.standard.data(forKey: "encryption_key") {
            return key
        } else {
            var key = Data(count: 64)
            _ = key.withUnsafeMutableBytes { pointer in
                SecRandomCopyBytes(kSecRandomDefault, 64, pointer.baseAddress!)
            }
            UserDefaults.standard.set(key, forKey: "encryption_key")
            return key
        }
    }
    
    func didTapTransactionCell(transactionID: String, viewController: UIViewController) {
        
    }
    
    func getSupportChatsAndManagers(callBack: @escaping (([String : Any]) -> Void)) {
        let dict: [String: Any] = [
            "supportChats": [
                [
                  "reception": 32,
                  "receptionService": 32,
                  "name": "Цифра Брокер",
                  "avatarUrl": "https://tradernet.ru/data/images/receptions_settings/file-6645cb72a5d69.png"
                ],
                [
                  "reception": 36,
                  "receptionService": 36,
                  "name": "FF Казахстан",
                  "avatarUrl": nil
                ]
              ],
              "personalManagers": [
                [
                  "userId": 3016423,
                  "nickname": "Денис Черепков",
                  "avatarUrl": nil
                ],
                [
                  "userId": 1880932,
                  "nickname": "Вера Заколодяжная",
                  "avatarUrl": nil
                ]
              ],
              "assistant": [
                "name": "AI Ассистент",
                "avatarUrl": "https://tradernet.ru/data/images/receptions_settings/file-6645cb72a5d69.png"
              ]
        ]
        callBack(dict)
    }
    
    func getMessageMeta() -> Dictionary<String, String> {
        return ["platform": "iOS"]
    }

    func didOpenConversation(with peers: [String]) { }
    
    func didUpdateVoipToken(_ token: String) { }
    
    func set<T>(_ value: T?, forKey key: String) {
        userDefaults?.set(value, forKey: key)
    }
    
    func removeObject(forKey key: String) {
        userDefaults?.set(nil, forKey: key)
    }
    
    func int(forKey key: String) -> Int? {
        userDefaults?.integer(forKey: key)
    }
    
    func string(forKey key: String) -> String? {
        userDefaults?.string(forKey: key)
    }
    
    func bool(forKey key: String) -> Bool? {
        userDefaults?.bool(forKey: key)
    }

}
