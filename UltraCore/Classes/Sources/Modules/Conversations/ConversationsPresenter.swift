//
//  ConversationsPresenter.swift
//  Pods
//
//  Created by Slam on 4/20/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import RxSwift
import Foundation
import RealmSwift
import IGListKit

final class ConversationsPresenter: BasePresenter {

    // MARK: - Private properties -
    private let updateRepository: UpdateRepository
    private let messageRepository: MessageRepository
    private unowned let view: ConversationsViewInterface
    private let wireframe: ConversationsWireframeInterface
    private let conversationRepository: ConversationRepository
    private let retrieveContactStatusesInteractor: UseCase<Void, Void>
    fileprivate let userStatusUpdateInteractor: UseCase<Bool, UpdateStatusResponse>
    
    lazy var conversation: Observable<[Conversation]> = Observable.combineLatest(conversationRepository.conversations(), updateRepository.typingUsers, updateRepository.unreadMessages)
        .map({ conversations, typingUsers, unreadMessages in
            return conversations.map { conversation in
                var mutable = conversation
                
                if let typing = typingUsers[conversation.idintification] {
                    mutable.typingData.removeAll(where: {$0.userId == typing.userId})
                    mutable.typingData.append(typing)
                    return mutable
                }
                mutable.unreadCount = Int(unreadMessages[conversation.idintification] ?? 0)
                return mutable
            }
        })
    
    // MARK: - Lifecycle -

    init(view: ConversationsViewInterface,
         updateRepository: UpdateRepository,
         messageRepository: MessageRepository,
         wireframe: ConversationsWireframeInterface,
         conversationRepository: ConversationRepository,
         retrieveContactStatusesInteractor: UseCase<Void, Void>,
         userStatusUpdateInteractor: UseCase<Bool, UpdateStatusResponse>) {
        self.view = view
        self.wireframe = wireframe
        self.updateRepository = updateRepository
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        self.userStatusUpdateInteractor = userStatusUpdateInteractor
        self.retrieveContactStatusesInteractor = retrieveContactStatusesInteractor
    }
    
}

// MARK: - Extensions -

extension ConversationsPresenter: ConversationsPresenterInterface {
    func retrieveContactStatuses() {
        self.retrieveContactStatusesInteractor.execute(params: ())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func updateStatus(is online: Bool) {
        self.userStatusUpdateInteractor.executeSingle(params: online)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func setupUpdateSubscription() {
        self.updateRepository.setupSubscription()
        self.updateRepository.sendPoingByTimer()
    }
    
    func navigate(to conversation: Conversation) {
        self.updateRepository.readAll(in: conversation)
        self.wireframe.navigateToConversation(with: conversation)
    }
    
    
    func navigateToContacts() {
        self.wireframe.navigateToContacts()
    }
}
