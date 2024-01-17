import Foundation
import RxSwift
import GRPC

class SessionInteractorImpl: UseCase<Void, Void> {
    
    override func executeSingle(params: Void) -> Single<Void> {
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
        return Single.create { observer -> Disposable in
            let userDef = UserDefaults.standard
            guard let number = userDef.string(forKey: "phone"),
                  let lastName = userDef.string(forKey: "last_name"),
                  let firstname = userDef.string(forKey: "first_name"),
                  let url = URL(string: "https://ultra-dev.typi.team/mock/v1/auth"),
                  let jsonData = try? JSONSerialization.data(withJSONObject: [
                      "phone": number,
                      "lastname": lastName,
                      "nickname": lastName,
                      "firstname": firstname,
                      "device_id": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
                  ]) else {
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data,
                          let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                    UserDefaults.standard.set(userResponse.sid, forKey: "K_SID")
                    UltraCoreSettings.update(sid: userResponse.sid) { error in
                        if let error = error {
                            observer(.failure(error))
                        } else {
                            observer(.success(()))
                        }
                    }
                }
            }
            
            task.resume()

            return Disposables.create()
        }
    }
}
