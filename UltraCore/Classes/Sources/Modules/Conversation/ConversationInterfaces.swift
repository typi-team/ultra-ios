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
    func openMoneyController(callback: @escaping MoneyCallback)
    func navigateToCall(response: CreateCallResponse, isVideo: Bool)
    func closeChat()
}

protocol ConversationViewInterface: ViewInterface {
    func setup(conversation: Conversation)
    func stopRefresh(removeController: Bool)
    func display(is typing: UserTypingWithDate)
    func reported()
    func blocked(is blocked: Bool)
    func showDisclaimer(show: Bool, delegate: DisclaimerViewDelegate)
    func showOnReceiveDisclaimer(delegate: DisclaimerViewDelegate, contact: ContactDisplayable?)
    func update(callAllowed: Bool)
}

protocol ConversationPresenterInterface: PresenterInterface {
    var conversation: Conversation { get set }
    var isManager: Bool { get }
    func block()
    func viewDidLoad()
    func loadIfFirstTime(seqNumber: UInt64) -> Bool
    func isBlock() -> Bool
    func navigateToContact()
    func typing(is active: Bool)
    func upload(file: ConversationPresenter.File)
    func send(message text: String)
    func send(location: LocationMessage)
    func send(contact: ContactMessage)
    func delete(_ messages: [Message], all: Bool)
    func loadMoreMessages(maxSeqNumber: UInt64)
    func mediaURL(from message: Message) -> URL?
    var messages: Observable<[Message]> { get set }
    func openMoneyController()
    func report(_ message: Message, with type: ComplainTypeEnum?, comment: String?)
    
    func allowedToCall() -> Bool
    func callVideo()
    func callVoice()
    func didTapTransfer()
    func isGroupChat() -> Bool
    func getContact(for id: String) -> ContactDisplayable?
    func canBlock() -> Bool
    func canTransfer() -> Bool
    func canAttach() -> Bool
    func canSendVoice() -> Bool
    func canSendVideo() -> Bool
    func canReport() -> Bool
}
