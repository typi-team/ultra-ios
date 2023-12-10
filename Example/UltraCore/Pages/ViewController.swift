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
    
    final let viewModel: ViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.viewDidLoad()
        self.setupView()
        self.setupVCs()
        self.setupSID()
    }
}

private extension ViewController {
    func createNavController(for rootViewController: UIViewController,
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
                $0.view.addSubview(UIButton.init({
                    $0.setTitle("Выйти", for: .normal)
                    $0.addTarget(self, action: #selector(self.logout(_:)), for: .touchUpInside)
                    $0.frame.origin = .init(x: 120, y: 120)
                    $0.frame.size = .init(width: 120, height: 52)
                    $0.setTitleColor(.green500, for: .normal)
                }))
            }), title: NSLocalizedString("Расходы", comment: ""), image: UIImage(named: "banence")!),
        ]
        
        self.selectedIndex = 3
    }
    
    func setupSID() {
        self.viewModel.setupSID(callback: {[weak self] error in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if error != nil {
                    self.viewControllers?.append(self.createNavController(for: UltraCoreSettings.entrySignUpViewController(), title: NSLocalizedString("conversations.chats", comment: ""), image: UIImage(named: "chats")!))
                    self.viewModel.timer()
                    UltraCoreSettings.printAllLocalizableStrings()
                } else {
                    self.viewControllers?.append(self.createNavController(for: UltraCoreSettings.entryConversationsViewController(), title: NSLocalizedString("conversations.chats", comment: ""), image: UIImage(named: "chats")!))
                }
                self.selectedIndex = 3
            }
        })
    }
    
    func setupView() {
        self.view.backgroundColor = .lightGray
        self.tabBar.tintColor = UIColor(red: 34.0 / 255.0, green: 197.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
    }
    
    @objc func logout(_ sender: Any) {
        UltraCoreSettings.logout()
    }
}