//
//  ConversationPresenter.swift
//  Pods
//
//  Created by Slam on 4/25/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import RxSwift
import RealmSwift

final class ConversationPresenter {

    // MARK: - Private properties -
    
    var conversation: Conversation
    
    fileprivate let userID: String
    fileprivate let disposeBag = DisposeBag()
    fileprivate let appStore: AppSettingsStore
    fileprivate let mediaRepository: MediaRepository
    fileprivate let updateRepository: UpdateRepository
    private unowned let view: ConversationViewInterface
    fileprivate let messageRepository: MessageRepository
    fileprivate let contactRepository: ContactsRepository
    private let wireframe: ConversationWireframeInterface
    fileprivate let conversationRepository: ConversationRepository
    private let sendTypingInteractor: UseCase<String, SendTypingResponse>
    private let readMessageInteractor: UseCase<Message, MessagesReadResponse>
    private let uploadFileInteractor: UseCase<[FileChunk], FileChunk>
    private let messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>
    private let createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>

    // MARK: - Public properties -

    lazy var messages: Observable<[Message]> = messageRepository.messages(chatID: conversation.idintification)
        .do(onNext: {[weak self ] messages in
            guard let `self` = self else { return }
            let messages = messages.filter({ $0.photo.fileID != "" })
            guard !messages.isEmpty else { return }

            Observable.from(messages)
                .flatMap { message in
                    return self.mediaRepository.download(from: message)
                }
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { next in
                    print("downloaded image in \(next.photo.fileID) ")
                })
                .disposed(by: self.disposeBag)
        
    })

    // MARK: - Lifecycle -

    init(userID: String,
         appStore: AppSettingsStore,
         conversation: Conversation,
         view: ConversationViewInterface,
         mediaRepository: MediaRepository,
         updateRepository: UpdateRepository,
         messageRepository: MessageRepository,
         contactRepository: ContactsRepository,
         wireframe: ConversationWireframeInterface,
         conversationRepository: ConversationRepository,
         sendTypingInteractor: UseCase<String, SendTypingResponse>,
         readMessageInteractor: UseCase<Message, MessagesReadResponse>,
         uploadFileInteractor: UseCase<[FileChunk], FileChunk>,
         messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>,
         createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>) {
        self.view = view
        self.userID = userID
        self.appStore = appStore
        self.wireframe = wireframe
        self.conversation = conversation
        self.mediaRepository = mediaRepository
        self.updateRepository = updateRepository
        self.contactRepository = contactRepository
        self.messageRepository = messageRepository
        self.uploadFileInteractor = uploadFileInteractor
        self.sendTypingInteractor = sendTypingInteractor
        self.readMessageInteractor = readMessageInteractor
        self.conversationRepository = conversationRepository
        self.messageSenderInteractor = messageSenderInteractor
        self.createFileSpaceInteractor = createFileSpaceInteractor
    }
}

// MARK: - Extensions -

extension ConversationPresenter: ConversationPresenterInterface {
    func upload(image data: Data, width: CGFloat, height: CGFloat) {
        
        var params = MessageSendRequest()
        
        params.peer.user = .with({ [weak self] peer in
            guard let `self` = self else { return }
            peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
        })
        
        var message = Message.with { mess in
            mess.receiver = .with({ [weak self] receiver in
                guard let `self` = self else { return }
                receiver.chatID = conversation.idintification
                receiver.userID = self.conversation.peer?.userID ?? ""
            })
            mess.meta = .with { $0.created = Date().nanosec }
            mess.sender = .with { $0.userID = self.userID }
            mess.id = UUID().uuidString
            mess.photo = .with({ photo in
                photo.fileName = ""
                photo.fileSize = Int64(data.count)
                photo.mimeType = "image/png"
                photo.height = Int32(height)
                photo.width = Int32(width)
            })
        }
        
        params.message = message
        
        self.createFileSpaceInteractor
            .executeSingle(params: (data, "png"))
            .flatMap({ [weak self] response -> Single<[FileChunk]> in
                guard let `self` = self, let firstChunk = response.first else {
                    throw NSError.selfIsNill
                }
                message.photo.fileID = firstChunk.fileID
                return self.messageRepository.save(message: message).map({response})
            })
            .asObservable()
            .flatMap({ [weak self] response -> Observable<Bool> in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.uploadFileInteractor.execute(params: response).map({response.last == $0})
            })
            .flatMapLatest({ isUploaded -> Single<MessageSendResponse?>in
                guard isUploaded else { return Single.just(nil)}
                return self.messageSenderInteractor.executeSingle(params: params).map({$0})
            })
            .compactMap({$0})
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { next in
                print("uploadmessage")
            })
            .disposed(by: disposeBag)
    }
    
    func typing(is active: Bool) {
        self.sendTypingInteractor
            .executeSingle(params: conversation.idintification)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    func viewDidLoad() {
        self.view.setup(conversation: conversation)
        self.updateRepository.typingUsers
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .map { [weak self] users -> UserTypingWithDate? in
                guard let `self` = self else { return nil }
                return users[self.conversation.idintification]
            }
            .compactMap { $0 }
            .subscribe (onNext: { [weak self] typingUser in
                guard let `self` = self else { return }
                self.view.display(is: typingUser)
            })
            .disposed(by: disposeBag)
        
        if let userID = self.conversation.peer?.userID {
            self.contactRepository
                .contacts()
                .map { $0.filter({ contact in contact.userID == userID }) }
                .compactMap({ $0.first })
                .subscribe(onNext: { [weak self] contact in
                    guard let `self` = self else { return }
                    self.conversation.peer = contact
                    self.view.setup(conversation: self.conversation)
                })
                .disposed(by: disposeBag)
        }
        
        self.messageRepository.messages(chatID: conversation.idintification)
            .debounce(RxTimeInterval.milliseconds(400), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] messages in
                guard let `self` = self else { return }
                let unreadMessages = messages.filter({ $0.sender.userID != self.appStore.userID() }).filter({ $0.state.read == false })
                guard let lastUnreadMessage = unreadMessages.last else { return }
                self.readMessageInteractor.executeSingle(params: lastUnreadMessage)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func send(message text: String) {
        var params = MessageSendRequest()
        
        params.peer.user = .with({ [weak self] peer in
            guard let `self` = self else { return }
            peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
        })
        params.message.text = text
        params.message.id = UUID().uuidString
        params.message.meta.created = Date().nanosec
        
        var message = Message()
        message.text = text
        message.id = params.message.id
        message.receiver = .with({[weak self] receiver in
            guard let `self` = self else { return }
            receiver.chatID = conversation.idintification
            receiver.userID = self.conversation.peer?.userID ?? ""
        })
        message.sender = .with({ $0.userID = self.userID })
        message.meta = .with({
            $0.created = Date().nanosec
        })
        
        self.conversationRepository
            .createIfNotExist(from: message)
            .flatMap{ self.messageRepository.save(message: message)}
            .flatMap{self.messageSenderInteractor.executeSingle(params: params)}
            .flatMap({ [weak self] (response: MessageSendResponse) in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                message.meta.created = response.meta.created
                message.state.delivered = false
                message.state.read = false
                message.seqNumber = response.seqNumber

                return self.messageRepository.update(message: message)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}

extension Message {
    var isIncome: Bool { self.receiver.userID == AppSettingsImpl.shared.appStore.userID() }
}


private extension ConversationPresenter {
    
}
