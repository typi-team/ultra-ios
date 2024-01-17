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

    func viewDidLoad() {
        UltraCoreSettings.delegate = self
        UltraCoreSettings.futureDelegate = self
    }
    
    var phone: String? {UserDefaults.standard.string(forKey: "phone") }
    
    func setupSID(callback: @escaping (Error?) -> Void) {
        token { [weak self] token in
            guard let token = token else {
                callback(NSError(domain: "SID is Empty", code: 101))
                return
            }
            self?.didRegisterForRemoteNotifications()
            UltraCoreSettings.update(sid: token, with: callback)
        }
    }
    
    func didRegisterForRemoteNotifications() {
        guard let url = URL(string: "https://ultra-dev.typi.team/mock/v1/device"),
              let firebaseToken = Messaging.messaging().fcmToken,
              let sidToken = UserDefaults.standard.string(forKey: "K_SID"),
              let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let jsonData = try? JSONSerialization.data(withJSONObject: [
                  "app_version": appVersion,
                  "token": firebaseToken,
                  "device_id": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
                  "platform": "IOS",
                  "voip_push_token": ""
              ]) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.setValue(sidToken, forHTTPHeaderField: "SID")
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
    
    func localize(for key: String) -> String? {
        nil
    }
    
    func availableToSendMoney() -> Bool {
        return false
    }
}

extension ViewModel: UltraCoreSettingsDelegate {
    func token(callback: @escaping StringCallback) {
        let userDef = UserDefaults.standard
        guard UserDefaults.standard.string(forKey: "K_SID") != nil,
              let lastname = userDef.string(forKey: "last_name"),
              let firstname = userDef.string(forKey: "first_name"),
              let phone = userDef.string(forKey: "phone") else {
            return callback(nil)
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
            .retry(when: { errors in
                return errors.enumerated().flatMap { (attempt, error) -> Observable<Int> in
                    let maxAttempts = 20
                    if attempt > maxAttempts {
                        return Observable.error(error)
                    }
                    return Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance)
                }
            })
            .subscribe { userResponse in
                callback(userResponse.sid)
            } onError: { error in
                callback(nil)
            }
            .disposed(by: disposeBag)
    }
    
    func emptyConversationView() -> UIView? {
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

}
