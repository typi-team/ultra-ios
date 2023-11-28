//
//  ViewController.swift
//  UltraCore
//
//  Created by rakish.shalkar@gmail.com on 04/13/2023.
//  Copyright (c) 2023 rakish.shalkar@gmail.com. All rights reserved.
//

import UIKit
import UltraCore


class ViewController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UltraCoreSettings.delegate = self
        UltraCoreSettings.futureDelegate = self
        self.view.backgroundColor = .lightGray
        self.tabBar.tintColor = UIColor(red: 34.0 / 255.0, green: 197.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
        self.setupVCs()
        self.selectedIndex = 3
        self.setupSID()
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController,
                                                      title: String,
                                                      image: UIImage) -> UIViewController {
            let navController = UINavigationController(rootViewController: rootViewController)
            navController.tabBarItem.title = title
            navController.tabBarItem.image = image
            navController.navigationBar.prefersLargeTitles = false
            navController.navigationItem.largeTitleDisplayMode = .never
            rootViewController.navigationItem.title = title
            return navController
        }
    
    func setupVCs() {
           viewControllers = [
               createNavController(for: UIViewController({
                   $0.view.backgroundColor = UIColor(red: 243.0 / 255.0, green: 244.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
               }), title: NSLocalizedString("Продукты", comment: ""), image: UIImage(named: "cards")!),
               createNavController(for: UIViewController({
                   $0.view.backgroundColor = UIColor(red: 243.0 / 255.0, green: 244.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
               }), title: NSLocalizedString("Платежи", comment: ""), image: UIImage(named: "payments")!),
               createNavController(for: UIViewController({
                   $0.view.backgroundColor = UIColor(red: 243.0 / 255.0, green: 244.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
               }), title: NSLocalizedString("Расходы", comment: ""), image: UIImage(named: "banence")!),
           ]
       }
    
    func setupSID() {
        UltraCoreSettings.update(sid: UserDefaults.standard.string(forKey: "K_SID") ?? "") { [weak self] error in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if error != nil {
                    self.viewControllers?.append(self.createNavController(for: UltraCoreSettings.entrySignUpViewController(), title: NSLocalizedString("conversations.chats", comment: ""), image: UIImage(named: "chats")!))
                    self.timer()
                    UltraCoreSettings.printAllLocalizableStrings()
                } else {
                    self.viewControllers?.append(self.createNavController(for: UltraCoreSettings.entryConversationsViewController(), title: NSLocalizedString("conversations.chats", comment: ""), image: UIImage(named: "chats")!))
                }
                self.selectedIndex = 3
            }
        }
    }
    
    var timerUpdate: Timer?
    func timer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
            self.timerUpdate = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
            self.timerUpdate?.fire()
        })
    }
    
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

extension ViewController: UltraCoreFutureDelegate {
    func localize(for key: String) -> String? {
        nil
    }
    
    func availableToSendMoney() -> Bool {
        return true
    }
}

extension ViewController: UltraCoreSettingsDelegate {
    func emptyConversationView() -> UIView? {
        return nil
    }
    
    func info(from id: String) -> UltraCore.IContactInfo? {
        return nil
    }
    
    /// Метод для реализаций страницы контактов
    /// - Parameters:
    ///   - callback: для сохранения контактов, можно использовать для сохранения массива контактной книги или одиночной сохранения контакта, перед началом переписки
    ///   - userCallback: для начало переписки, перед вызовом надо скрыть ваш контроллер
    /// - Returns: Контроллер для отображения ваших контактов
    func contactsViewController(contactsCallback: @escaping ContactsCallback, openConverationCallback: @escaping UserIDCallback) -> UIViewController? {
        return nil
    }

    func serverConfig() -> ServerConfigurationProtocol? {
        return nil
    }
    
    /// Метод для реализаций страницы передачи денег
    /// - Parameter callback: для передачи сообщения о переводе денег
    /// - Returns: Контроллер для передачи денег с указаннием суммы
    func moneyViewController(callback: @escaping MoneyCallback) -> UIViewController? {
        return nil
    }
    
    func contactViewController(contact id: String) -> UIViewController? {
        return nil
    }
}

struct ServerConfig: ServerConfigurationProtocol {
    var portOfServer: Int = 443
    var pathToServer: String = "ultra-dev.typi.team"
}

struct Contact: IContactInfo {
    var userID: String
    var phone: String
    var lastname: String
    var firstname: String
}
