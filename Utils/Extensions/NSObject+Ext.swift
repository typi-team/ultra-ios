//
//  NSObject+Ext.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import Foundation

extension NSObject {
    convenience init(modify: ((Self) -> Void)) {
        self.init()
        modify(self as! Self)
    }
}
