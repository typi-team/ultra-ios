//
//  ConversationsInterfaces.swift
//  Pods
//
//  Created by Slam on 4/20/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import RealmSwift
import RxSwift

protocol ConversationsWireframeInterface: WireframeInterface {
    func navigateToConversation(with data: Conversation, isPersonalManager: Bool)
    func navigateToContacts(contactsCallback: @escaping ContactsCallback, openConverationCallback: @escaping UserIDCallback)
}

protocol ConversationsViewInterface: ViewInterface {
}

protocol ConversationsPresenterInterface: PresenterInterface {
    var conversation: Observable<[Conversation]> { get set }
    
    func navigateToContacts()
    func delete(_ conversation: Conversation, all: Bool)
    func navigate(to conversation: Conversation)
}
