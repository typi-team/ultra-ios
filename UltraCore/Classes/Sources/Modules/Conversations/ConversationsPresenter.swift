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
    fileprivate let contactDBService: ContactDBService
    private let conversationRepository: ConversationRepository
    private let retrieveContactStatusesInteractor: UseCase<Void, Void>
    fileprivate let contactByUserIdInteractor: ContactByUserIdInteractor
    fileprivate let userStatusUpdateInteractor: UseCase<Bool, UpdateStatusResponse>
    fileprivate let deleteConversationInteractor: UseCase<(Conversation, Bool), Void>
    fileprivate let contactToCreateChatByPhoneInteractor: ContactToCreateChatByPhoneInteractor
    
    lazy var conversation: Observable<[Conversation]> = Observable.combineLatest(conversationRepository.conversations(), updateRepository.typingUsers, updateRepository.unreadMessages)
        .map({ conversations, typingUsers, unreadMessages in
            return conversations.map { conversation in
                var mutable = conversation
                
                if let typing = typingUsers[conversation.idintification] {
                    mutable.typingData.removeAll(where: {$0.userId == typing.userId})
                    mutable.typingData.append(typing)
                }
                mutable.unreadCount = Int(unreadMessages[conversation.idintification] ?? 0)
                return mutable
            }
        })
    
    // MARK: - Lifecycle -

    init(view: ConversationsViewInterface,
         updateRepository: UpdateRepository,
         messageRepository: MessageRepository,
         contactDBService: ContactDBService,
         wireframe: ConversationsWireframeInterface,
         conversationRepository: ConversationRepository,
         contactByUserIdInteractor: ContactByUserIdInteractor,
         retrieveContactStatusesInteractor: UseCase<Void, Void>,
         deleteConversationInteractor: UseCase<(Conversation,Bool), Void>,
         contactToCreateChatByPhoneInteractor: ContactToCreateChatByPhoneInteractor,
         userStatusUpdateInteractor: UseCase<Bool, UpdateStatusResponse>) {
        self.view = view
        self.wireframe = wireframe
        self.updateRepository = updateRepository
        self.messageRepository = messageRepository
        self.contactDBService = contactDBService
        self.conversationRepository = conversationRepository
        self.contactByUserIdInteractor = contactByUserIdInteractor
        self.userStatusUpdateInteractor = userStatusUpdateInteractor
        self.deleteConversationInteractor = deleteConversationInteractor
        self.retrieveContactStatusesInteractor = retrieveContactStatusesInteractor
        self.contactToCreateChatByPhoneInteractor = contactToCreateChatByPhoneInteractor
    }
}

// MARK: - Extensions -

extension ConversationsPresenter: ConversationsPresenterInterface {
    func delete(_ conversation: Conversation, all: Bool) {
        self.deleteConversationInteractor.executeSingle(params: (conversation, all))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
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
        self.wireframe.navigateToContacts(contactsCallback: { contacts in },
                                          openConverationCallback: { [weak self] userID in
                                              guard let `self` = self else { return }
                                              self.createChatBy(contact: userID)
                                          })
    }
    
    func createChatBy(contact: IContact) {
        self.contactToCreateChatByPhoneInteractor
            .executeSingle(params: contact)
            .flatMap({ contactByPhone -> Single<Conversation> in
                self.contactByUserIdInteractor.executeSingle(params: contactByPhone.userID)
                    .flatMap({ contact in
                        self.contactDBService.save(contact: contact).map({contact})
                    }).map({ ConversationImpl(contact: $0, idintification: contactByPhone.chatID) })
                    
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] conversation in
                
                self?.wireframe.navigateToConversation(with: conversation)
            })
            .disposed(by: disposeBag)
    }
}
