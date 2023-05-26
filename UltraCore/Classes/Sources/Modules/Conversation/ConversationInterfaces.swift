//
//  ConversationInterfaces.swift
//  Pods
//
//  Created by Slam on 4/25/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import RxSwift
import RealmSwift

protocol ConversationWireframeInterface: WireframeInterface {
}

protocol ConversationViewInterface: ViewInterface {
    func setup(conversation: Conversation)
    func display(is typing: UserTypingWithDate)
}

protocol ConversationPresenterInterface: PresenterInterface {
    func viewDidLoad()
    func typing(is active: Bool)
    func send(message text: String)
    var messages: Observable<Results<DBMessage>> { get set }
}