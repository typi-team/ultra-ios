//
//  ViewModel.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//
import UltraCore
import Foundation

class ViewModel {
    fileprivate var timerUpdate: Timer?
    
    func viewDidLoad() {
        UltraCoreSettings.delegate = self
        UltraCoreSettings.futureDelegate = self
    }
    
    func setupSID(callback: @escaping (Error?) -> Void) {
                UltraCoreSettings.update(sid: UserDefaults.standard.string(forKey: "K_SID") ?? "", with: callback) 
    }
    
    func timer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
            self.timerUpdate = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
            self.timerUpdate?.fire()
        })
    }
}

private extension ViewModel {
    @objc func runTimedCode(_ sender: Any) {
        let userDef = UserDefaults.standard
        guard let lastname = userDef.string(forKey: "last_name"),
              let firstname = userDef.string(forKey: "first_name"),
              let phone = userDef.string(forKey: "phone")else  {
                  return
        }
        self.login(lastName: lastname, firstname: firstname, phone: phone)
    }
    
    func login(lastName: String, firstname: String, phone number: String) {
        
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
        
        guard let url = URL(string: "https://ultra-dev.typi.team/mock/v1/auth"),
              let jsonData = try? JSONSerialization.data(withJSONObject: [
                  "phone": number,
                  "lastname": lastName,
                  "firstname": firstname,
                  "nickname": firstname,
              ]) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
             if let data = data,
                      let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                 UltraCoreSettings.update(sid: userResponse.sid, with: {_ in })
            }
        }
        
        task.resume()
    }
}


extension ViewModel: UltraCoreFutureDelegate {
    func availableToRecordVoice() -> Bool {
        false
    }
    
    func availableToReport(message: Any) -> Bool {
        false
    }
    
    func localize(for key: String) -> String? {
        nil
    }
    
    func availableToSendMoney() -> Bool {
        return false
    }
}

extension ViewModel: UltraCoreSettingsDelegate {
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
