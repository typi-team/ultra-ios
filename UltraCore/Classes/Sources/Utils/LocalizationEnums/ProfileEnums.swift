//
//  ProfileEnums.swift
//  UltraCore
//
//  Created by Slam on 12/8/23.
//

import Foundation

enum ProfileEnums: String, StringLocalizable  {
    
    case profile
    case phone
    case detail
    
    var prefixOfTemplate: String { "profile" }
    var localizableValue: String { rawValue }
    
}
