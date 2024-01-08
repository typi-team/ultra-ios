//
//  ViewModel.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//
import UltraCore
import Foundation

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
    
    func viewDidLoad() {
        UltraCoreSettings.delegate = self
        UltraCoreSettings.futureDelegate = self
    }
    
    func setupSID(callback: @escaping (Error?) -> Void) {
        let userDef = UserDefaults.standard
        guard UserDefaults.standard.string(forKey: "K_SID") != nil,
              let lastname = userDef.string(forKey: "last_name"),
              let firstname = userDef.string(forKey: "first_name"),
              let phone = userDef.string(forKey: "phone") else {
            return callback(NSError(domain: "SID is Empty", code: 101))
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
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                UltraCoreSettings.update(sid: userResponse.sid, with: callback)
            }
        }.resume()
    }

    func timer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] _ in
//                self?.setupSID(callback: { _ in })
            })
        })
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
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                callback(userResponse.sid)
            }
        }.resume()
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
