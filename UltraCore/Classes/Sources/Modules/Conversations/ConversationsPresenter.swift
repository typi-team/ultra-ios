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
    fileprivate let contactByUserIdInteractor: ContactByUserIdInteractor
    fileprivate let deleteConversationInteractor: UseCase<(Conversation, Bool), Void>
    fileprivate let contactToConversationInteractor: ContactToConversationInteractor
    fileprivate let resendMessagesInteractor: ResendingMessagesInteractor
    fileprivate let reachabilityInteractor: ReachabilityInteractor
    fileprivate let isSupport: Bool
    fileprivate var personalManagers: [String] = []
    
    lazy var conversation: Observable<[Conversation]> = Observable.combineLatest(
        conversationRepository.conversations(),
        updateRepository.typingUsers,
        updateRepository.updateSyncObservable.debug("Updated Sync"),
        updateRepository.supportOfficesObservable
    )
        .map({ conversations, typingUsers, _, supportOffices in
            let personalManagers = supportOffices?.personalManagers ?? []
            let managers = personalManagers.map { String($0.userId) }
            let offices = supportOffices?.supportChats ?? []
            self.personalManagers = managers
            return conversations
                .map ({ conv in
                    var conversation = conv
                    if conversation.chatType == .peerToPeer {
                        if let peer = conversation.peers.first, let manager = personalManagers.first(where: { String($0.userId) == peer.phone }) {
                            conversation.title = manager.nickname
                        } else {
                            conversation.title = conversation.peers.first?.displaName ?? ""
                        }
                    }
                    return conversation
                })
                .filter { [weak self] conversation in
                    guard let self = self else {
                        return true
                    }
//                    PP.debug("Conversation peers are \(conversation.peers.map(\.phone)); type - \(conversation.chatType) - \(conversation.title), chat ID - \(conversation.idintification); personal managers - \(self.personalManagers); isSupport - \(isSupport)")
                    if isSupport {
                        if conversation.chatType == .support && conversation.isAssistant {
                            return supportOffices?.assistant != nil
                        } else if conversation.chatType == .support {
                            return true
                        } else if conversation.chatType == .peerToPeer {
                            guard let peer = conversation.peers.first else {
                                return false
                            }
                            return managers.contains(where: { $0 == peer.phone })
                        } else {
                            return false
                        }
                    } else if conversation.chatType == .peerToPeer {
                        return conversation.lastMessage != nil
                    }
                    
                    return conversation.chatType != .support
                }
                .sorted(by: { conv1, conv2 in
                    return conv1.isAssistant
                })
                .map { conversation in
                    var mutable = conversation
                    if let typing = typingUsers[conversation.idintification] {
                        mutable.typingData.removeAll(where: {$0.userId == typing.userId})
                        mutable.typingData.append(typing)
                    }
                    return mutable
                }
        })
    
    // MARK: - Lifecycle -

    init(
        view: ConversationsViewInterface,
        isSupport: Bool,
        updateRepository: UpdateRepository,
        contactDBService: ContactDBService,
        wireframe: ConversationsWireframeInterface,
        conversationRepository: ConversationRepository,
        contactByUserIdInteractor: ContactByUserIdInteractor,
        deleteConversationInteractor: UseCase<(Conversation,Bool), Void>,
        contactToConversationInteractor: ContactToConversationInteractor,
        resendMessagesInteractor: ResendingMessagesInteractor,
        reachabilityInteractor: ReachabilityInteractor
    ) {
        self.view = view
        self.isSupport = isSupport
        self.wireframe = wireframe
        self.updateRepository = updateRepository
        self.contactDBService = contactDBService
        self.conversationRepository = conversationRepository
        self.contactByUserIdInteractor = contactByUserIdInteractor
        self.deleteConversationInteractor = deleteConversationInteractor
        self.resendMessagesInteractor = resendMessagesInteractor
        self.reachabilityInteractor = reachabilityInteractor
        self.contactToConversationInteractor = contactToConversationInteractor
    }
}

// MARK: - Extensions -

extension ConversationsPresenter: ConversationsPresenterInterface {
    
    var isSupportScreen: Bool {
        self.isSupport
    }
    
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
    
    func navigate(to conversation: Conversation) {
        self.updateRepository.readAll(in: conversation)
        if let peer = conversation.peers.first, personalManagers.contains(where: { $0 == peer.phone }) {
            self.wireframe.navigateToConversation(with: conversation, isPersonalManager: true)
        } else {
            self.wireframe.navigateToConversation(with: conversation, isPersonalManager: false)
        }
    }
    
    func isManager(conversation: Conversation) -> Bool {
        if conversation.chatType == .peerToPeer {
            guard let peer = conversation.peers.first else {
                return false
            }
            return personalManagers.contains(where: { $0 == peer.phone })
        }
        
        return false
    }
    
    func navigateToContacts() {
        self.wireframe.navigateToContacts(
            contactsCallback: { contacts in },
            openConverationCallback: { [weak self] userID in
                guard let `self` = self else { return }
                self.wireframe.dissmiss {
                    self.createChatBy(contact: userID)
                }
            })
    }
    
    func createChatBy(contact: IContact) {
        // TO-DO: Show loader when executing conversation
        self.contactToConversationInteractor
            .executeSingle(params: contact)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] conversation in
                guard let self = self else { return }
                if let conversation = conversation {
                    if let peer = conversation.peers.first, personalManagers.contains(where: { $0 == peer.phone }) {
                        self.wireframe.navigateToConversation(with: conversation, isPersonalManager: true)
                    } else {
                        self.wireframe.navigateToConversation(with: conversation, isPersonalManager: false)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func startReachibilityNotifier() {
        reachabilityInteractor.execute(params: ())
            .debounce(.seconds(10), scheduler: ConcurrentDispatchQueueScheduler(qos: .utility))
//            .flatMap({ [weak self] _ -> Observable<Void> in
//                guard let self = self else {
//                    return Observable.error(NSError.selfIsNill)
//                }
//                if !self.updateRepository.isConnectedToListenStream {
//                    return Observable.error(CustomError.notConnected)
//                }
//                
//                return Observable.just(())
//            })
//            .retry(when: { errors in
//                return errors.enumerated().flatMap { attempt, error in
//                    if error == CustomError.notConnected {
//                        return Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance)
//                    }
//                    
//                    return Observable.error(error)
//                }
//            })
            .debug("Reachability")
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.resendMessagesInteractor
                    .executeSingle(params: ())
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}

private enum CustomError: Error {
    case notConnected
}
