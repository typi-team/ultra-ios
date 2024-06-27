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
import AVFoundation

final class ConversationPresenter {

    // MARK: - Private properties -
    
    var conversation: Conversation
    
    fileprivate let userID: String
    fileprivate let disposeBag = DisposeBag()
    fileprivate let appStore: AppSettingsStore
    
    fileprivate let callService: CallServiceClientProtocol
    
    fileprivate let mediaRepository: MediaRepository
    fileprivate let updateRepository: UpdateRepository
    private weak var view: ConversationViewInterface?
    fileprivate let messageRepository: MessageRepository
    fileprivate let contactRepository: ContactsRepository
    private let wireframe: ConversationWireframeInterface
    fileprivate let conversationRepository: ConversationRepository
    
    private let blockContactInteractor: GRPCErrorUseCase<BlockParam, Void>
    private let deleteMessageInteractor: GRPCErrorUseCase<([Message], Bool), Void>
    private let sendTypingInteractor: GRPCErrorUseCase<String, SendTypingResponse>
    private let readMessageInteractor: GRPCErrorUseCase<Message, MessagesReadResponse>
    private let messagesInteractor: GRPCErrorUseCase<GetChatMessagesRequest, [Message]>
    fileprivate let sendMoneyInteractor: UseCase<TransferPayload, TransferResponse>
    private let makeVibrationInteractor: UseCase<UIImpactFeedbackGenerator.FeedbackStyle, Void>
    private let messageSenderInteractor: GRPCErrorUseCase<MessageSendRequest, MessageSendResponse>
    private let messageSentSoundInteractor: UseCase<MakeSoundInteractor.Sound, Void>
    private let acceptContactInteractor: GRPCErrorUseCase<String, Void>
    private let isPersonalManager: Bool
    
    // MARK: - Public properties -

    lazy var messages: Observable<[Message]> = messageRepository.messages(chatID: conversation.idintification)
        .map({ $0.sorted(by: { m1, m2 in m1.meta.created < m2.meta.created }) })
        .do(onNext: { [weak self] messages in
            guard let `self` = self else { return }
            let messages = messages.filter({ $0.fileID != nil })
                .filter({ [weak self] in self?.mediaRepository.mediaURL(from: $0) == nil })
            guard !messages.isEmpty else { return }

            Observable.from(messages)
                .flatMap { [weak self] message in
                    guard let self else { throw NSError.selfIsNill }
                    return mediaRepository.download(from: message)
                }
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .observe(on: MainScheduler.instance)
                .subscribe()
                .disposed(by: disposeBag)
        })

    // MARK: - Lifecycle -

    init(
        userID: String,
        isPersonalManager: Bool,
        appStore: AppSettingsStore,
        conversation: Conversation,
        view: ConversationViewInterface,
        mediaRepository: MediaRepository,
        callService: CallServiceClientProtocol,
        updateRepository: UpdateRepository,
        messageRepository: MessageRepository,
        contactRepository: ContactsRepository,
        wireframe: ConversationWireframeInterface,
        conversationRepository: ConversationRepository,
        deleteMessageInteractor: GRPCErrorUseCase<([Message], Bool), Void>,
        blockContactInteractor: GRPCErrorUseCase<BlockParam, Void>,
        messagesInteractor: GRPCErrorUseCase<GetChatMessagesRequest, [Message]>,
        sendTypingInteractor: GRPCErrorUseCase<String, SendTypingResponse>,
        readMessageInteractor: GRPCErrorUseCase<Message, MessagesReadResponse>,
        sendMoneyInteractor: UseCase<TransferPayload, TransferResponse>,
        
        makeVibrationInteractor: UseCase<UIImpactFeedbackGenerator.FeedbackStyle, Void>,
        messageSenderInteractor: GRPCErrorUseCase<MessageSendRequest, MessageSendResponse>,
        messageSentSoundInteractor: UseCase<MakeSoundInteractor.Sound, Void>,
        acceptContactInteractor: GRPCErrorUseCase<String, Void>
    ) {

        self.view = view
        self.isPersonalManager = isPersonalManager
        self.userID = userID
        self.appStore = appStore
        self.wireframe = wireframe
        self.callService = callService
        self.conversation = conversation
        self.mediaRepository = mediaRepository
        self.updateRepository = updateRepository
        self.contactRepository = contactRepository
        self.messageRepository = messageRepository
        self.messagesInteractor = messagesInteractor
        self.sendMoneyInteractor = sendMoneyInteractor
        self.sendTypingInteractor = sendTypingInteractor
        self.readMessageInteractor = readMessageInteractor
        self.blockContactInteractor = blockContactInteractor
        self.conversationRepository = conversationRepository
        self.deleteMessageInteractor = deleteMessageInteractor
        self.messageSenderInteractor = messageSenderInteractor
        self.makeVibrationInteractor = makeVibrationInteractor
        self.messageSentSoundInteractor = messageSentSoundInteractor
        self.acceptContactInteractor = acceptContactInteractor
    }
}

// MARK: - Extensions -

extension ConversationPresenter: ConversationPresenterInterface {
    
    func canBlock() -> Bool {
        conversation.chatType != .support && !isManager
    }
    
    func canTransfer() -> Bool {
        conversation.chatType != .support && !isManager
    }
    
    func canAttach() -> Bool {
        !conversation.isAssistant
    }
    
    func canSendVoice() -> Bool {
        conversation.chatType != .support && !isManager
    }
    
    func canSendVideo() -> Bool {
        conversation.chatType != .support && !isManager
    }
    
    var isManager: Bool {
        return self.isPersonalManager
    }
    
    func isGroupChat() -> Bool {
        return conversation.chatType == .support || conversation.chatType == .group
    }
    
    func getContact(for id: String) -> ContactDisplayable? {
        contactRepository.contact(id: id)
    }
    
    func allowedToCall() -> Bool {
        conversation.callAllowed && conversation.chatType != .support
    }

    func subscribeToVisibility() {
        guard conversation.chatType == .peerToPeer else {
            return
        }
        if let userID = self.conversation.peers.first?.userID {
            let timerUpdate = Observable<Int>.interval(.seconds(30), scheduler: MainScheduler.instance)
            let contacts = self.contactRepository.contacts().do { [weak self] contacts in
                guard let `self` = self,
                      let selectedContact = contacts.filter({ contact in contact.userID == userID }).first else { return }
                self.conversation.peers = [selectedContact]
                self.view?.blocked(is: selectedContact.isBlocked)
                self.view?.setup(conversation: self.conversation)
                
            }
            updateRepository.updateSyncObservable
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.view?.setup(conversation: self.conversation)
                })
                .disposed(by: disposeBag)
            Observable.combineLatest(timerUpdate, contacts)
                .compactMap { _, contacts -> ContactDisplayable? in
                    let selectedContact = contacts.filter { contact in contact.userID == userID }.first
                    return selectedContact
                }
                .do(onNext: { [weak self] contact in
                    guard let `self` = self else { return }
                    self.conversation.peers = [contact]
                    self.view?.blocked(is: contact.isBlocked)
                    self.view?.setup(conversation: self.conversation)
                })
                .subscribe()
                .disposed(by: disposeBag)
        }
    }

    func isBlock() -> Bool {
        return self.conversation.peers.first?.isBlocked ?? false
    }
    
    func block() {
        guard let contact = self.conversation.peers.first else { return }
        let userId = contact.userID
        self.blockContactInteractor
            .executeSingle(params: (userId, !contact.isBlocked))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe (onFailure:  {[weak self ]error in
                guard let `self` = self else { return }
                self.view?.show(error: error.localeError)
            }).disposed(by: self.disposeBag)
    }

    
    func report(_ message: Message, with type: ComplainTypeEnum?, comment: String?) {
        let request = ComplainRequest.with({
            $0.messageID = message.id
            $0.comment = comment ?? ""
            $0.chatID = self.conversation.idintification
            $0.type = comment == nil ? .other : type ?? .other
        })
        print(request.textFormatString())
        AppSettingsImpl.shared.messageService.complain(request, callOptions: .default()).response
            .whenComplete({[weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.view?.reported()
                    case let .failure(error):
                        self.view?.show(error: error.localeError)
                    }
                }
            })
    }
    func callVideo() {
        self.createCall(with: true)
    }
    
    func callVoice() {
        self.createCall()
    }
    
    func createCall(with video: Bool = false) {
        guard let user = self.conversation.peers.first?.userID else { return }
        self.callService.create(.with({
            $0.users = [user]
            $0.video = video
        }), callOptions: .default())
            .response
            .whenComplete({ [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case let .success(response):
                    PP.debug("[CALL] create call response - \(response.host), \(response.room), \(response.accessToken)")
                    DispatchQueue.main.async {
                        self.wireframe.navigateToCall(response: response, isVideo: video)
                    }
                case let .failure(error):
                    PP.error(error.localizedDescription)
                }
            })
    }
    
    func send(location: LocationMessage) {
        var params = MessageSendRequest()
        if let messageMeta = UltraCoreSettings.delegate?.getMessageMeta() {
            params.message.properties = messageMeta
        }
        
        params.updatePeer(with: conversation)

        var message = Message()
        message.id = UUID().uuidString
        message.meta.created = Date().nanosec
        message.receiver = .from(conversation: conversation)
        message.location = location
        
        message.sender = .with({ $0.userID = self.userID })
        message.meta = .with({
            $0.created = Date().nanosec
        })
        if let messageMeta = UltraCoreSettings.delegate?.getMessageMeta() {
            message.properties = messageMeta
        }
        
        params.message = message
        
        self.conversationRepository
            .createIfNotExist(from: message)
            .flatMap({ [weak self] in
                guard let self else { throw NSError.selfIsNill }
                return messageRepository.save(message: message)
            })
            .flatMap({ [weak self] in
                guard let self else { throw NSError.selfIsNill }
                return messageSenderInteractor.executeSingle(params: params)
            })
            .flatMap({ [weak self] (response: MessageSendResponse) in
                guard let self else { throw NSError.selfIsNill }
                message.meta.created = response.meta.created
                message.state.delivered = false
                message.state.read = false
                message.seqNumber = response.seqNumber
                return messageRepository.update(message: message)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.playSentMessageSound()
            })
            .disposed(by: disposeBag)
    }
    
    func send(contact: ContactMessage) {
        var params = MessageSendRequest()
        
        params.updatePeer(with: conversation)
        if let messageMeta = UltraCoreSettings.delegate?.getMessageMeta() {
            params.message.properties = messageMeta
        }

        var message = Message()
        message.id = UUID().uuidString
        message.meta.created = Date().nanosec
        message.receiver = .from(conversation: conversation)
        message.contact = contact
        
        message.sender = .with({ $0.userID = self.userID })
        message.meta = .with({
            $0.created = Date().nanosec
        })
        
        params.message = message
        
        self.conversationRepository
            .createIfNotExist(from: message)
            .flatMap{ self.messageRepository.save(message: message)}
            .flatMap{self.messageSenderInteractor.executeSingle(params: params)}
            .flatMap({ [weak self] (response: MessageSendResponse) in
                guard let self else { throw NSError.selfIsNill }
                message.meta.created = response.meta.created
                message.state.delivered = false
                message.state.read = false
                message.seqNumber = response.seqNumber
                return messageRepository.update(message: message)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.playSentMessageSound()
            })
            .disposed(by: disposeBag)
    }
    
    func delete(_ messages: [Message], all: Bool) {
        deleteMessageInteractor.executeSingle(params: (messages, all))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func openMoneyController() {
        wireframe.openMoneyController(callback: { [weak self] value in
            guard let self, let receiverID = self.conversation.peers.first?.userID else { return }
            var params = MessageSendRequest()

            params.peer.user = .with({ peer in
                peer.userID = receiverID
            })

            params.message.id = UUID().uuidString
            params.message.meta.created = Date().nanosec

            var message = Message()
            message.money = .with({
                $0.transactionID = value.transactionID
                $0.money = .with({ money in
                    money.units = value.amout
                    money.currencyCode = value.currency
                })
            })
            message .text = params.textFormatString()
            message.id = params.message.id
            message.receiver = .with({ receiver in
                receiver.userID = receiverID
                receiver.chatID = self.conversation.idintification
            })
            message.sender = .with({ $0.userID = self.userID })
            message.meta = .with({ $0.created = Date().nanosec })
            params.message = message
            
            if let messageMeta = UltraCoreSettings.delegate?.getMessageMeta() {
                params.message.properties = messageMeta
            }
            
            self.conversationRepository
                .createIfNotExist(from: message)
                .flatMap({ [weak self] in
                    guard let self else { throw NSError.selfIsNill }
                    return messageRepository.save(message: message)
                })
                .flatMap({ [weak self] in
                    guard let self else { throw NSError.selfIsNill }
                    return messageSenderInteractor.executeSingle(params: params)
                })
                .flatMap({ [weak self] (response: MessageSendResponse) in
                    guard let self else { throw NSError.selfIsNill }
                    message.meta.created = response.meta.created
                    message.state.delivered = false
                    message.state.read = false
                    message.seqNumber = response.seqNumber
                    return messageRepository.update(message: message)
                })
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] _ in
                    self?.playSentMessageSound()
                })
                .disposed(by: disposeBag)
        })
    }
    
    func loadMoreMessages(maxSeqNumber: UInt64 ) {
        PP.debug("Loading more message for chat - \(conversation.idintification) seqNumber - \(maxSeqNumber)")
        messagesInteractor
            .executeSingle(params: .with({ [weak self] in
                guard let self else { return }
                $0.chatID = conversation.idintification
                $0.maxSeqNumber = UInt64(maxSeqNumber)
            }))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] message in
                PP.debug("Finished loading messages for chat - \(self?.conversation.idintification ?? "")")
                PP.debug("[Message] Loaded messages: - \(message)")
                self?.view?.stopRefresh(removeController: message.isEmpty)
            })
            .disposed(by: disposeBag)
    }
    func navigateToContact() {
        guard conversation.chatType == .peerToPeer, !isPersonalManager else { return }
        guard let contact = self.conversation.peers.first else { return }
        wireframe.navigateTo(contact: contact)
    }
    
    func mediaURL(from message: Message) -> URL? {
        return mediaRepository.mediaURL(from: message)
    }
    
    func upload(file: File) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            switch file {
            case let .video(url):
                guard let data = try? Data(contentsOf: url) else { return }
                self?.upload(
                    file: .init(
                        url: url,
                        data: data,
                        mime: "video/mp4",
                        width: 300,
                        height: 200
                    ),
                    isVoice: false
                )
            case let .image(image):
                guard let self else { return }
                let downsampled = image.fixedOrientation()
                let resizedImage = resizeImage(image: downsampled)
                upload(
                    file: .init(
                        url: nil,
                        data: resizedImage.0,
                        mime: "image/jpeg",
                        width: resizedImage.1.width,
                        height: resizedImage.1.height
                    ),
                    isVoice: false
                )
            case let .file(url):
                guard let data = try? Data(contentsOf: url) else { return }
                self?.upload(
                    file: .init(
                        url: url,
                        data: data,
                        mime: url.mimeType().containsAudio ? "audio/mp3" : url.mimeType(),
                        width: 300,
                        height: 300
                    ),
                    isVoice: false
                )
            case let .audio(url, duration):
                guard let data = try? Data(contentsOf: url) else { return }
                self?.upload(
                    file: FileUpload(
                        url: nil,
                        data: data,
                        mime: "audio/wav",
                        width: 0,
                        height: 0,
                        duration: duration
                    ),
                    isVoice: true
                )
            }
        }
    }
    
    private func upload(file: FileUpload, isVoice: Bool) {
        mediaRepository
            .upload(
                file: file,
                in: conversation,
                isVoice: isVoice,
                onPreUploadingFile: { [weak self] request in
                guard let self else { return }
                self.conversationRepository
                    .createIfNotExist(from: request.message)
                    .flatMap{ self.messageRepository.save(message: request.message)}
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .subscribe()
                    .disposed(by: disposeBag)
                }
            )
            .flatMap({ [weak self] request in
                guard let self else { throw NSError.selfIsNill }
                return messageSenderInteractor.executeSingle(params: request)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] response in
                guard let self, var message = messageRepository.message(id: response.messageID) else {
                    return
                }

                message.meta.created = response.meta.created
                message.seqNumber = response.seqNumber
                update(message: message)
                playSentMessageSound()
            },
                       onFailure: { error in PP.debug(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func resizeImage(image: UIImage, maxDimension: CGFloat = 1280) -> (Data, CGSize) {
        let size = image.size
        guard max(size.width, size.height) > maxDimension else {
            return (image.jpegData(compressionQuality: 1) ?? Data(), size)
        }
        let widthRatio  = maxDimension / size.width
        let heightRatio = maxDimension / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let newImage = renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        if let data = compressTo(0.512, image: newImage) {
            return (data, size)
        }
        return (image.jpegData(compressionQuality: 1) ?? Data(), size)
    }

    private func compressTo(_ expectedSizeInMb: CGFloat, image: UIImage) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress: Bool = true
        var imgData: Data?
        var compressingValue: CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data = image.jpegData(compressionQuality: compressingValue) {
                if data.count < Int(sizeInBytes) {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        if let data = imgData {
            if (data.count < Int(sizeInBytes)) {
                return data
            }
        }
        return nil
    }
    
    private func playSentMessageSound() {
        messageSentSoundInteractor
            .executeSingle(params: .messageSent)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func update(message: Message) {
        messageRepository
            .update(message: message)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func typing(is active: Bool) {
        sendTypingInteractor
            .executeSingle(params: conversation.idintification)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func loadIfFirstTime(seqNumber: UInt64) -> Bool {
        guard !appStore.loadState(for: conversation.idintification) else {
            return false
        }
        
        appStore.saveLoadState(for: conversation.idintification)
        return true
    }
    
    func viewDidLoad() {
        subscribeToVisibility()
        view?.setup(conversation: conversation)
        if conversation.addContact && conversation.seqNumber > 0 {
            view?.showOnReceiveDisclaimer(delegate: self, contact: conversation.peers.first)
        } else if conversation.addContact {
            view?.showDisclaimer(show: true, delegate: self)
        }
        
        if conversation.chatType != .support {
            UltraCoreSettings.delegate?.didOpenConversation(with: conversation.peers.map(\.phone))
        }
        
        updateRepository.typingUsers
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .map { [weak self] users -> UserTypingWithDate? in
                guard let self else { return nil }
                return users[conversation.idintification]
            }
            .compactMap { $0 }
            .subscribe (onNext: { [weak self] typingUser in
                self?.view?.display(is: typingUser)
            })
            .disposed(by: disposeBag)
        
        messageRepository.messages(chatID: conversation.idintification)
            .debounce(RxTimeInterval.milliseconds(400), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] messages in
                guard let self else { return }
                let unreadMessages = messages.filter({ $0.sender.userID != self.appStore.userID() }).filter({ $0.state.read == false })
                guard let lastUnreadMessage = unreadMessages.last else { return }
                updateRepository.readAll(in: self.conversation)
                readMessageInteractor.executeSingle(params: lastUnreadMessage)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .subscribe()
            .disposed(by: disposeBag)
        conversationRepository
            .callAllowed(for: conversation.idintification)
            .debug("CALLALLOWED")
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isAllowed in
                self?.view?.update(callAllowed: isAllowed)
            }
            .disposed(by: disposeBag)
    }
    
    func send(message text: String) {
        var params = MessageSendRequest()
        
        params.updatePeer(with: conversation)
        params.message.text = text
        params.message.id = UUID().uuidString
        params.message.meta.created = Date().nanosec
        
        if let messageMeta = UltraCoreSettings.delegate?.getMessageMeta() {
            params.message.properties = messageMeta
        }
        
        var message = Message()
        message.text = text
        message.id = params.message.id
        message.receiver = .from(conversation: conversation)
        message.sender = .with({ [weak self] in
            guard let self else { return }
            $0.userID = userID
        })
        message.meta = .with({
            $0.created = Date().nanosec
        })
        
        conversationRepository
            .createIfNotExist(from: message)
            .flatMap({ [weak self] in
                guard let self else { throw NSError.selfIsNill }
                return messageRepository.save(message: message)
            })
            .flatMap({ [weak self] in
                guard let self else { throw NSError.selfIsNill }
                return messageSenderInteractor.executeSingle(params: params)
            })
            .flatMap({ [weak self] (response: MessageSendResponse) in
                guard let self else { throw NSError.selfIsNill }
                message.meta.created = response.meta.created
                message.state.delivered = false
                message.state.read = false
                message.seqNumber = response.seqNumber
                return messageRepository.update(message: message)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] _ in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.makeVibrationInteractor.executeSingle(params: .light)
            })
            .subscribe(onSuccess: { [weak self] _ in
                self?.playSentMessageSound()
            })
            .disposed(by: disposeBag)
    }
    
    func didTapTransfer() {
        guard conversation.chatType == .peerToPeer,
              let userID = conversation.peers.first?.phone,
              let viewController = view as? UIViewController
        else {
            return
        }
        UltraCoreSettings.delegate?.provideTransferScreen(
            for: userID,
            viewController: viewController,
            transferCallback: { [weak self] moneyTransfer in
                guard let self, let receiverID = self.conversation.peers.first?.userID else { return }
                var params = MessageSendRequest()

                params.peer.user = .with({ peer in
                    peer.userID = receiverID
                })

                params.message.id = UUID().uuidString
                params.message.meta.created = Date().nanosec

                var message = Message()
                message.money = .with({
                    $0.transactionID = moneyTransfer.transactionID
                    $0.money = .with({ money in
                        money.units = moneyTransfer.amout
                        money.currencyCode = moneyTransfer.currency
                    })
                })
                message.text = params.textFormatString()
                message.id = params.message.id
                message.receiver = .with({ receiver in
                    receiver.userID = receiverID
                    receiver.chatID = self.conversation.idintification
                })
                message.sender = .with({ $0.userID = self.userID })
                message.meta = .with({ $0.created = Date().nanosec })
                
                params.message = message
                
                if let messageMeta = UltraCoreSettings.delegate?.getMessageMeta() {
                    params.message.properties = messageMeta
                }
                
                self.conversationRepository
                    .createIfNotExist(from: message)
                    .flatMap({ [weak self] in
                        guard let self else { throw NSError.selfIsNill }
                        return messageRepository.save(message: message)
                    })
                    .flatMap({ [weak self] in
                        guard let self else { throw NSError.selfIsNill }
                        return messageSenderInteractor.executeSingle(params: params)
                    })
                    .flatMap({ [weak self] (response: MessageSendResponse) in
                        guard let self else { throw NSError.selfIsNill }
                        message.meta.created = response.meta.created
                        message.state.delivered = false
                        message.state.read = false
                        message.seqNumber = response.seqNumber
                        return messageRepository.update(message: message)
                    })
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .subscribe(onSuccess: { [weak self] _ in
                        self?.playSentMessageSound()
                    })
                    .disposed(by: disposeBag)
            }
        )
    }

}

extension ConversationPresenter: DisclaimerViewDelegate {
    func disclaimerDidTapAgree() {
        guard let userID = self.conversation.peers.first?.userID else {
            return
        }
        acceptContactInteractor
            .executeSingle(params: userID)
            .observe(on: MainScheduler.instance)
            .do(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.conversationRepository
                    .update(addContact: false, for: self.conversation.idintification)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.view?.showDisclaimer(show: false, delegate: self)
            } onFailure: { [weak self] error in
                self?.view?.show(error: error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    func disclaimerDidTapClose() {
        wireframe.closeChat()
    }
}

extension ConversationPresenter {
    enum File {
        case audio(url: URL, duration: TimeInterval)
        case video(url: URL)
        case image(image: UIImage)
        case file(url: URL)
    }
}
