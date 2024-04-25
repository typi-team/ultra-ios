//
//  DBSystemMesageModels.swift
//  UltraCore
//
//  Created by Typi on 24.04.2024.
//

import Foundation
import RealmSwift

class DBSystemActionSupportManagerAssigned: Object {
    @objc dynamic var userID: String = ""
    
    init(action: SystemActionSupportManagerAssigned) {
        self.userID = action.userID
    }
}

class DBSystemActionSupportStatusChanged {
    @objc dynamic var status: Int = 0
    
    init(action: SystemActionSupportStatusChanged) {
        self.status = action.status.rawValue
    }
}
