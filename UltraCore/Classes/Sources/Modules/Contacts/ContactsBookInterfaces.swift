//
//  ContactsBookInterfaces.swift
//  Pods
//
//  Created by Slam on 4/21/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import RxSwift
import RealmSwift


protocol ContactsBookWireframeInterface: WireframeInterface {
    func openConversation(with contact: ContactDisplayable)
}

protocol ContactsBookViewInterface: ViewInterface {
    func permission(is denied: Bool)
    func contacts(is empty: Bool)
}


protocol ContactsBookPresenterInterface: PresenterInterface {
    
    func initial()
    func openConversation(with contact: ContactDisplayable)
    var contacts: Observable<[Contact]> { get set }
}
