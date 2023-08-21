//
//  IContact.swift
//  UltraCore
//
//  Created by Slam on 5/19/23.
//

import Foundation

public protocol IContact {
    var phone: String { get set }
    var userID: String { get set }
    var lastname: String { get set }
    var firstname: String { get set }
}

extension Contact: IContact {}

public typealias ContactsCallback = ([IContact]) -> Void


