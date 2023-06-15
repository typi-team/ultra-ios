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
               createNavController(for: entryViewController(delegate: self), title: NSLocalizedString("Чаты", comment: ""), image: UIImage(named: "chats")!)
           ]
       }
}

extension ViewController: UCAppDelegate {
    func ssid() -> String? {
        return nil
    }
    
    func signUpView() -> UIViewController? {
        return nil
    }
}
