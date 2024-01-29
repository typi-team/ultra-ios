//
//  AppSettingsStore.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol AppSettingsStore {
    func userID() -> String
    func store(token: String)
    func store(userID: String)
    func store(last state: Int64)
    
    var token: String?  { get set }
    var lastState: Int64 { get }
    var ssid: String? { get set }
    func deleteAll()
}

class AppSettingsStoreImpl {
    fileprivate let kSID = "kSSID"
    fileprivate let kUserID = "kUserID"
    fileprivate let kLastState = "kLastState"
    fileprivate let userDefault = UserDefaults(suiteName: "com.ultaCore.messenger")
    
    var ssid: String?
    var token: String?
}

extension AppSettingsStoreImpl: AppSettingsStore {
    
    func store(last state: Int64) {
        self.userDefault?.set(state, forKey: kLastState)
    }
    
    var lastState: Int64 {
        return (self.userDefault?.value(forKey: kLastState) as? Int64) ?? 0
    }
    
    func userID() -> String {
        guard let token = self.userDefault?.string(forKey: kUserID) else {
            fatalError("call store(userID:) before call this function")
        }
        return token
    }
    
    func store(userID: String) {
        self.userDefault?.set(userID, forKey: kUserID)
    }
    
    func store(token: String) {
        self.token = token
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
