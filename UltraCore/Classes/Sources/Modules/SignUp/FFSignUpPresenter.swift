//
//  FFSignUpPresenter.swift
//  UltraCore
//
//  Created by Slam on 6/15/23.
//

import RxSwift

final class FFSignUpPresenter {
    
    private weak var view: SignUpViewInterface?
    fileprivate let wireframe: SignUpWireframeInterface
    
    // MARK: - Lifecycle -g
    init(view: SignUpViewInterface,
         wireframe: SignUpWireframeInterface) {
        self.view = view
        self.wireframe = wireframe
    }
}

// MARK: - Extensions -
extension FFSignUpPresenter: SignUpPresenterInterface {
    
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
    
    func login(lastName: String, firstname: String, phone number: String) {
    
        let userDef = UserDefaults.standard
        userDef.set(lastName, forKey: "last_name")
        userDef.set(firstname, forKey: "first_name")
        userDef.set(number, forKey: "phone")
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
                  "nickname": lastName,
                  "firstname": firstname,
                  "device_id": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
              ]) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {[weak self] (data, response, error) in
            guard let `self` = self else { return }
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data,
                      let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                UserDefaults.standard.set(userResponse.sid, forKey: "K_SID")
                UltraCoreSettings.update(sid: userResponse.sid) {[weak self] error in
                    if let error = error {
                        PP.warning(error.localizedDescription)
                    } else if let `self` = self {
                        DispatchQueue.main.async {
                            self.view?.open(view: UltraCoreSettings.entryConversationsViewController())
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
}


fileprivate extension SignUpPresenter {

}
