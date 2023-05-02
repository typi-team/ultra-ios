//
//  AppSettingsStore.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol AppSettingsStore {
    func token() -> String
    func userID() -> String
    func store(token: String)
    func store(userID: String)
    var isAuthed: Bool { get }
}

class AppSettingsStoreImpl {
    fileprivate let kToken = "kToken"
    fileprivate let kUserID = "kUserID"
    fileprivate let userDefault = UserDefaults(suiteName: "com.ultaCore.messenger")
}

extension AppSettingsStoreImpl: AppSettingsStore {
    func userID() -> String {
        guard let token = self.userDefault?.string(forKey: kUserID) else {
            fatalError("call store(userID:) before call this function")
        }
        return token
    }
    
    func store(userID: String) {
        self.userDefault?.set(userID, forKey: kUserID)
    }
    
    
    var isAuthed: Bool { self.userDefault?.string(forKey: kToken) != nil }
    
    func store(token: String) {
        self.userDefault?.set(token, forKey: kToken)
    }
    
    func token() -> String {
        guard let token = self.userDefault?.string(forKey: kToken) else {
            fatalError("call store(token:) before call this function")
        }
        return token
    }
}
