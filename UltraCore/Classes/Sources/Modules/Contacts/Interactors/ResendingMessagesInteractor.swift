import RxSwift
import Foundation

protocol ResendingMessagesInteractorProtocol {
    func viewDidLoad()
}

class ResendingMessagesInteractor: ResendingMessagesInteractorProtocol {
    
    // MARK: - Properties
    
    private let reachability = try? Reachability()
    
    private var messageSending: Array<String> = []
        
    private let messageRepository: MessageRepository
    
    private let messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>
    
    private let mediaRepository: MediaRepository
    
    private lazy var disposeBag = DisposeBag()

    // MARK: - Init
    
    init(
        messageRepository: MessageRepository,
        mediaRepository: MediaRepository,
        messageSenderInteractor: UseCase<MessageSendRequest, MessageSendResponse>
    ) {
        self.messageRepository = messageRepository
        self.messageSenderInteractor = messageSenderInteractor
        self.mediaRepository = mediaRepository
    }

    // MARK: - ResendingMessagesInteractorProtocol
    
    func viewDidLoad() {
        startReachibilityNotifier()
    }
    
    // MARK: - Methods
    
    private func resendMessagesIfNeeded() {
        getAllMessages { [weak self] messages in
            guard let self else { return }
            let unsendedMessages = messages.filter { $0.seqNumber == 0 && !$0.isIncome }
            unsendedMessages.forEach { message in
                guard !self.messageSending.contains(message.id) else { return }
                self.messageSending.append(message.id)
                if let content = message.content {
                    switch content {
                    case .audio, .voice, .photo, .video, .file:
                        self.resendFiles(message: message)
                    default:
                        self.resendMessage(message: message)
                    }
                } else {
                    self.resendMessage(message: message)
                }
            }
        }
    }
    
    func resendFiles(message: Message) {
        self.mediaRepository
            .upload(message: message)
            .flatMap({ [weak self] request in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageSenderInteractor.executeSingle(params: request)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { _ in },
                       onFailure: { error in PP.debug(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    private func resendMessage(message: Message) {
        var message = message
        var params = MessageSendRequest()
        params.peer.user = .with({ peer in
            peer.userID = message.receiver.userID
        })
        params.message = message
        messageSenderInteractor
            .executeSingle(params: params)
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
            .disposed(by: disposeBag)
    }
    
    private func startReachibilityNotifier() {
        reachability?.whenReachable = { [weak self] reachability in
            self?.messageSending.removeAll()
            self?.resendMessagesIfNeeded()
        }
        try? reachability?.startNotifier()
    }
    
    private func getAllMessages(onCompletion: @escaping ([Message]) -> Void) {
        messageRepository
            .messages()
            .map({ $0.sorted(by: { m1, m2 in m1.meta.created < m2.meta.created }) })
            .subscribe(onNext: { messages in
                onCompletion(messages)
            })
            .disposed(by: disposeBag)
    }
        
}
