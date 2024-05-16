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
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.viewModel.setupSID(callback: {[weak self] error in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if error != nil {
                    self.viewControllers?.append(self.createNavController(for: UltraCoreSettings.entrySignUpViewController(), title: NSLocalizedString("conversations.chats", comment: ""), image: UIImage(named: "chats")!))
                } else {
                    self.viewControllers?.append(self.createNavController(for: UltraCoreSettings.entryConversationsViewController(isSupport: false), title: NSLocalizedString("conversations.chats", comment: ""), image: UIImage(named: "chats")!))
                }
                self.selectedIndex = 3
            }
        })
        
        viewModel.onUnreadMessagesUpdated = { [weak self] count in
            let chatTabbar = self?.tabBar.items?.first(where: { $0.title == NSLocalizedString("conversations.chats", comment: "") })
            if count <= 0 {
                chatTabbar?.badgeValue = nil
            } else {
                chatTabbar?.badgeValue = String(count)
            }
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didEnterBackground(_ sender: Any) {
        UltraCoreSettings.stopSession()
    }

    @objc func didEnterForeground(_ sender: Any) {
        UltraCoreSettings.updateSession(callback: { _ in })
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
                $0.view.addSubview(UIButton.init({
                    $0.setTitle("Логи", for: .normal)
                    $0.addTarget(self, action: #selector(self.exportLogs(_:)), for: .touchUpInside)
                     $0.frame.origin = .init(x: 120, y: 120)
                     $0.frame.origin = .init(x: 120, y: 240)
                     $0.frame.size = .init(width: 120, height: 52)
                     $0.setTitleColor(.green500, for: .normal)
                 }))
            }), title: NSLocalizedString("Платежи", comment: ""), image: UIImage(named: "payments")!),
            createNavController(for: UIViewController({
                $0.view.addSubview(UILabel{
                    $0.text = viewModel.phone
                    $0.frame.origin = .init(x: 120, y: 120)
                    $0.frame.size = .init(width: 120, height: 52)
                })
               $0.view.backgroundColor = UIColor(red: 243.0 / 255.0, green: 244.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
               $0.view.addSubview(UIButton.init({
                   $0.setTitle("Выйти", for: .normal)
                   $0.addTarget(self, action: #selector(self.logout(_:)), for: .touchUpInside)
                    $0.frame.origin = .init(x: 120, y: 120)
                    $0.frame.origin = .init(x: 120, y: 240)
                    $0.frame.size = .init(width: 120, height: 52)
                    $0.setTitleColor(.green500, for: .normal)
                }))

            }), title: NSLocalizedString("Расходы", comment: ""), image: UIImage(named: "banence")!),
        ]
        
        self.selectedIndex = 3
    }
    
    func setupView() {
        self.view.backgroundColor = .lightGray
        self.tabBar.tintColor = UIColor(red: 34.0 / 255.0, green: 197.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
    }
    
    @objc func logout(_ sender: Any) {
        UltraCoreSettings.logout()
    }
    
    @objc func exportLogs(_ sender: Any) {
        PP.getLogFile { [weak self] fileURL in
            let activity = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            self?.present(activity, animated: true)
        }
    }
}
