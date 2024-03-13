//
//  AppDelegate.swift
//  UltraCore
//
//  Created by rakish.shalkar@gmail.com on 04/13/2023.
//  Copyright (c) 2023 rakish.shalkar@gmail.com. All rights reserved.
//
import UltraCore
import UIKit
import FirebaseCore
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setDefaultStyleSettings()
        self.setupNotificationSettings(application: application)
        UltraVoIPManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
}

extension AppDelegate {
    func setupNotificationSettings(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Ошибка при регистрации push-уведомлений: \(error.localizedDescription)")
            }
        }
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let token = Messaging.messaging().fcmToken else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            UltraCoreSettings.update(firebase: token, voipToken: UltraVoIPManager.shared.token)
            ViewModel().didRegisterForRemoteNotifications()
        })
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Ошибка при регистрации push-уведомлений: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Обработка нажатия на уведомление
        UltraCoreSettings.handleNotification(data: response.notification.request.content.userInfo) { viewController in
            guard let viewController = viewController else { return }
            self.window?.rootViewController?.present(UINavigationController(rootViewController: viewController), animated: true)
        }
        completionHandler()
    }
}
