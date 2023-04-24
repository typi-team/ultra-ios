//
//  Error+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/24/23.
//

import Foundation

extension NSError {
    static var selfIsNill: NSError {
        NSError.init(domain: "Skip this error, because self is nil", code: 101)
    }
}
