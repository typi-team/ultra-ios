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
    func navigateToContacts()
    func navigateToConversation(with data: Conversation)
}

protocol ConversationsViewInterface: ViewInterface {
}

protocol ConversationsPresenterInterface: PresenterInterface {
    var conversation: Observable<Results<DBConversation>> { get set }
    
    func navigateToContacts()
    func setupUpdateSubscription()
    func navigate(to conversation: Conversation)
}
