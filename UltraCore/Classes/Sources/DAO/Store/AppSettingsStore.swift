//
//  AppSettingsStore.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol AppSettingsStore {
    func userID() -> String
    func deviceID() -> String
    func store(token: String)
    func store(userID: String)
    func store(last state: Int64)
    func saveLoadState(for chatID: String)
    func loadState(for chatID: String) -> Bool
    
    var token: String?  { get set }
    var lastState: Int64 { get }
    var ssid: String? { get set }
    func deleteAll()
}

class AppSettingsStoreImpl {
    fileprivate let kSID = "kSSID"
    fileprivate let kUserID = "kUserID"
    fileprivate let kLastState = "kLastState"
    fileprivate let kDeviceID = "kDeviceID"
    fileprivate let userDefault = UserDefaults(suiteName: "com.ultaCore.messenger")
    
    var ssid: String?
    var token: String?
}

extension AppSettingsStoreImpl: AppSettingsStore {
    
    func store(last state: Int64) {
        PP.debug("Saved App Store state - \(state)")
        self.userDefault?.set(state, forKey: kLastState)
    }
    
    var lastState: Int64 {
        return (self.userDefault?.value(forKey: kLastState) as? Int64) ?? 0
    }
    
    func userID() -> String {
        guard let userID = self.userDefault?.string(forKey: kUserID) else {
            return ""
        }
        return userID
    }
    
    func deviceID() -> String {
        guard let deviceID = self.userDefault?.string(forKey: kDeviceID) else {
            let deviceID = UUID().uuidString
            self.userDefault?.set(deviceID, forKey: kDeviceID)
            return deviceID
        }
        
        return deviceID
    }
    
    func store(userID: String) {
        self.userDefault?.set(userID, forKey: kUserID)
    }
    
    func store(token: String) {
        self.token = token
    }
    
    func saveLoadState(for chatID: String) {
        let key = "chat_\(chatID)"
        userDefault?.set(true, forKey: key)
    }
    
    func loadState(for chatID: String) -> Bool {
        let key = "chat_\(chatID)"
        return userDefault?.bool(forKey: key) ?? false
    }
    
    func deleteAll() {
        token = nil
        ssid = nil
        [kSID,
         kUserID,
         kLastState].forEach({ key in
            self.userDefault?.removeObject(forKey: key)
        })
    }
}
