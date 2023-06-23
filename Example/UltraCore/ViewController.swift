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
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
            self.tabBar.tintColor =  UIColor(red: 34.0 / 255.0, green: 197.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
            self.setupVCs()
            self.selectedIndex = 3
            self.setupSID()
        }
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
        update(sid: UserDefaults.standard.string(forKey: "K_SID") ?? "") { [weak self] error in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.viewControllers?.append(self.createNavController(for: entrySignUpViewController(), title: NSLocalizedString("Чаты", comment: ""), image: UIImage(named: "chats")!))
                    self.timer()
                } else {
                    self.viewControllers?.append(self.createNavController(for: entryConversationsViewController(), title: NSLocalizedString("Чаты", comment: ""), image: UIImage(named: "chats")!))
                }
                self.selectedIndex = 3
            }
        }
    }
    
    var timerUpdate: Timer?
    func timer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 180, execute: {
            self.timerUpdate = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
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
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
             if let data = data,
                      let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                 update(sid: userResponse.sid, with: {_ in })
            }
        }
        
        task.resume()
    }

}
