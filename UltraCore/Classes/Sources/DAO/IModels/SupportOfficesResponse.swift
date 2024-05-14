//
//  SupportOfficesResponse.swift
//  UltraCore
//
//  Created by Typi on 13.05.2024.
//

import Foundation

struct SupportOfficesResponse: Codable {
    let support_chats: [SupportChat]
    let personal_managers: [PersonalManager]
    let assistant_enabled: Bool
}

struct SupportChat: Codable {
    let reception: Int
    let name: String
    let avatar: String?
}

struct PersonalManager: Codable {
    let user_id: String
    let nickname: String
}
