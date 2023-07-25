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
    func navigateTo(contact: ContactDisplayable)
}

protocol ConversationViewInterface: ViewInterface {
    func setup(conversation: Conversation)
    func stopRefresh(removeController: Bool)
    func display(is typing: UserTypingWithDate)
}

struct FileUpload {
    let url: URL?
    let data: Data
    let mime: MimeType
    let width: CGFloat
    let height: CGFloat
}

protocol ConversationPresenterInterface: PresenterInterface {
    func viewDidLoad()
    func navigateToContact()
    func typing(is active: Bool)
    func upload(file: FileUpload)
    func send(message text: String)
    func send(money amount: Double)
    func send(contact: ContactMessage)
    func delete(_ messages: [Message], all: Bool)
    func loadMoreMessages(maxSeqNumber: UInt64)
    func mediaURL(from message: Message) -> URL?
    var messages: Observable<[Message]> { get set }
}
