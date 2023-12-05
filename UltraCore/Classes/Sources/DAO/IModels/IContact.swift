//
//  IContact.swift
//  UltraCore
//
//  Created by Slam on 5/19/23.
//

import Foundation

public protocol IContact {
    var identifier : String { get set }
    var firstname: String { get set }
}

public protocol IContactInfo: IContact {
    var lastname: String { get set }
    var imagePath: String? {get set }
}

public typealias UserIDCallback = (IContact) -> Void
public typealias ContactsCallback = ([IContact]) -> Void
