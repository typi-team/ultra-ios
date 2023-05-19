//
//  ContactDisplayable.swift
//  UltraCore
//
//  Created by Slam on 5/19/23.
//

import Foundation


protocol ContactDisplayable: Any {
    var phone: String { get }
    var userID: String { get }
    var chatID: String { get }
    var displaName: String { get }
    var status: UserStatus { get }
}

extension DBContact : ContactDisplayable {
    var status: UserStatus {
        return .with({
            $0.lastSeen = lastseen
            $0.userID = userID
            $0.status = statusEnum
        })
    }
    
    var statusEnum: UserStatusEnum {
        return UserStatusEnum.init(rawValue: self.statusValue) ?? .UNRECOGNIZED(statusValue)
    }
    
    var displaName: String { [firstName, lastName].joined(separator: " ") }
}

extension Contact: ContactDisplayable {
    var chatID: String {
        let id = AppSettingsImpl.shared.appStore.userID()

        return "p\(id >= self.userID ? id + self.userID : self.userID + id)"
    }
    
    var displaName: String {
        return [firstname, lastname].joined(separator: " ")
    }
}
