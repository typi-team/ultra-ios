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
    private weak var view: ConversationsViewInterface?
    private let wireframe: ConversationsWireframeInterface
    fileprivate let contactDBService: ContactDBService
    private let conversationRepository: ConversationRepository
    private let retrieveContactStatusesInteractor: UseCase<Void, Void>
    fileprivate let contactByUserIdInteractor: ContactByUserIdInteractor
    fileprivate let userStatusUpdateInteractor: UseCase<Bool, UpdateStatusResponse>
    fileprivate let deleteConversationInteractor: UseCase<(Conversation, Bool), Void>
    fileprivate let contactToConversationInteractor: ContactToConversationInteractor
    fileprivate let resendMessagesInteractor: ResendingMessagesInteractor
    fileprivate let reachabilityInteractor: ReachabilityInteractor
    fileprivate let sessionInteractorImpl: SessionInteractorImpl
    
    lazy var conversation: Observable<[Conversation]> = Observable.combineLatest(conversationRepository.conversations(), updateRepository.typingUsers)
        .map({ conversations, typingUsers in
            return conversations.map { conversation in
                var mutable = conversation
                if let typing = typingUsers[conversation.idintification] {
                    mutable.typingData.removeAll(where: {$0.userId == typing.userId})
                    mutable.typingData.append(typing)
                }
                return mutable
            }
        })
    
    // MARK: - Lifecycle -

    init(view: ConversationsViewInterface,
         updateRepository: UpdateRepository,
         contactDBService: ContactDBService,
         wireframe: ConversationsWireframeInterface,
         conversationRepository: ConversationRepository,
         contactByUserIdInteractor: ContactByUserIdInteractor,
         retrieveContactStatusesInteractor: UseCase<Void, Void>,
         deleteConversationInteractor: UseCase<(Conversation,Bool), Void>,
         contactToConversationInteractor: ContactToConversationInteractor,
         userStatusUpdateInteractor: UseCase<Bool, UpdateStatusResponse>,
         resendMessagesInteractor: ResendingMessagesInteractor,
         reachabilityInteractor: ReachabilityInteractor,
         sessionInteractorImpl: SessionInteractorImpl) {
        self.view = view
        self.wireframe = wireframe
        self.updateRepository = updateRepository
        self.contactDBService = contactDBService
        self.conversationRepository = conversationRepository
        self.contactByUserIdInteractor = contactByUserIdInteractor
        self.userStatusUpdateInteractor = userStatusUpdateInteractor
        self.deleteConversationInteractor = deleteConversationInteractor
        self.retrieveContactStatusesInteractor = retrieveContactStatusesInteractor
        self.resendMessagesInteractor = resendMessagesInteractor
        self.reachabilityInteractor = reachabilityInteractor
        self.contactToConversationInteractor = contactToConversationInteractor
        self.sessionInteractorImpl = sessionInteractorImpl
    }
}

// MARK: - Extensions -

extension ConversationsPresenter: ConversationsPresenterInterface {
    
    func viewDidLoad() {
        startReachibilityNotifier()
    }
    
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
    
    func sendAway() {
        self.updateRepository.stopPingPong()
        self.userStatusUpdateInteractor.executeSingle(params: false)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func sendOnline() {
        self.userStatusUpdateInteractor.executeSingle(params: true)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
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
        self.contactToConversationInteractor
            .executeSingle(params: contact)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] conversation in
                if let conversation = conversation {
                    self?.wireframe.navigateToConversation(with: conversation)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func startReachibilityNotifier() {
        reachabilityInteractor.execute(params: ())
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.sessionInteractorImpl
                    .executeSingle(params: ())
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .subscribe(onSuccess: { _ in
                        self.resendMessagesInteractor
                            .executeSingle(params: ())
                            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                            .observe(on: MainScheduler.instance)
                            .subscribe()
                            .disposed(by: self.disposeBag)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    

}
