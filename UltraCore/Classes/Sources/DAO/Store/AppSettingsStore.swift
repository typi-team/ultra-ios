//
//  AppSettingsStore.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol AppSettingsStore {
    func token() -> String
    func store(token: String)
    var isAuthed: Bool { get }
}

class AppSettingsStoreImpl {
    fileprivate let kToken = "kToken"
    fileprivate let userDefault = UserDefaults(suiteName: "com.ultaCore.messenger")
}

extension AppSettingsStoreImpl: AppSettingsStore {
    
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
