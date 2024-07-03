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
    let assistant: PersonalAssistant?
}

struct SupportChat: Codable {
    let reception: Int
    let name: String
    let avatarUrl: String?
}

struct PersonalManager: Codable {
    let userId: Int
    let nickname: String
    let avatarUrl: String?
}

struct PersonalAssistant: Codable {
    let name: String
    let avatarUrl: String?
}
