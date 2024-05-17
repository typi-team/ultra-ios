//
//  SupportOfficesResponse.swift
//  UltraCore
//
//  Created by Typi on 13.05.2024.
//

import Foundation

struct SupportOfficesResponse: Codable {
    let supportChats: [SupportChat]
    let personalManagers: [PersonalManager]
    let assistantEnabled: Bool
}

struct SupportChat: Codable {
    let reception: Int
    let name: String
    let avatarUrl: String?
}

struct PersonalManager: Codable {
    let userId: String
    let nickname: String
    let avatarUrl: String?
}
