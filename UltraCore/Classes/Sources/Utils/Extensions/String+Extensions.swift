//
//  String+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/21/23.
//

import Foundation
extension String {
    var initails: String {
        let components = self.components(separatedBy: " ")
        var initials = ""
        for component in components {
            if let firstCharacter = component.first {
                initials.append(firstCharacter)
            }
        }
        return initials
    }
    
    var isValidPhone: Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: self)
        return result
    }
}
