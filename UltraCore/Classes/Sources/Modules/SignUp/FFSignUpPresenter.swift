//
//  FFSignUpPresenter.swift
//  UltraCore
//
//  Created by Slam on 6/15/23.
//

import RxSwift

final class FFSignUpPresenter {
    
    private unowned let view: SignUpViewInterface
    fileprivate let wireframe: SignUpWireframeInterface
    
    // MARK: - Lifecycle -
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
        
        guard let url = URL(string: "http://ultra-dev.typi.team:8086/v1/auth"),
              let jsonData = try? JSONSerialization.data(withJSONObject: [
                  "phone": number,
                  "lastname": lastName,
                  "firstname": firstname,
              ]) else { return }

        
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {[weak self] (data, response, error) in
            guard let `self` = self else { return }
            if let error = error {
                fatalError(error.localizedDescription)
            } else if let data = data,
                      let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                entryViewController(with: userResponse.sid) { controller in
                    self.view.open(view: controller)
                }

            } else {
                fatalError("Handle this case")
            }
        }
        
        task.resume()
    }
}


fileprivate extension SignUpPresenter {

}
