import RxSwift
import Foundation

final class ResendingMessagesInteractor: UseCase<Void, Void> {
    
    // MARK: - Properties
    
    private var messageSending: Array<String> = []
        
    private let messageRepository: MessageRepository
    
    private let messageSenderInteractor: SendMessageInteractor
    
    private let mediaRepository: MediaRepository
    
    private lazy var disposeBag = DisposeBag()

    // MARK: - Init
    
    init(
        messageRepository: MessageRepository,
        mediaRepository: MediaRepository,
        messageSenderInteractor: SendMessageInteractor
    ) {
        self.messageRepository = messageRepository
        self.messageSenderInteractor = messageSenderInteractor
        self.mediaRepository = mediaRepository
    }

    override func executeSingle(params: Void) -> Single<Void> {
        return Single<Void>
            .create { [weak self] observer -> Disposable in
                guard let `self` = self else { return Disposables.create() }
                self.resendMessagesIfNeeded()
                return Disposables.create()
            }
    }
    
    // MARK: - Methods
    
    private func resendMessagesIfNeeded() {
        messageSending.removeAll()
        getAllMessages { [weak self] messages in
            guard let self else { return }
            let unsendedMessages = messages.filter { $0.seqNumber == 0 && !$0.isIncome }
            var textMessages: [Message] = []
            var fileMessages: [Message] = []
            unsendedMessages.forEach { message in
                guard !self.messageSending.contains(message.id) else { return }
                self.messageSending.append(message.id)
                if let content = message.content {
                    switch content {
                    case .audio, .voice, .photo, .video, .file:
                        fileMessages.append(message)
                    default:
                        textMessages.append(message)
                    }
                } else {
                    textMessages.append(message)
                }
            }
            self.resendMessages(messages: textMessages) {
                self.resendFiles(messages: fileMessages) {
                    self.messageSending.removeAll()
                }
            }
        }
    }
    
    func resendFiles(messages: [Message], index: Int = 0, onCompletion:  @escaping () -> Void) {
        guard index < messages.count else {
            onCompletion()
            return
        }
        let message = messages[index]
        self.mediaRepository
            .upload(message: message)
            .flatMap({ [weak self] request in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageSenderInteractor.executeSingle(params: request)
            })
            .flatMap({ [weak self] (response: MessageSendResponse) in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.messageRepository.update(message: message)
            })
            .flatMap({ [weak self] result in
                self?.resendFiles(messages: messages, index: index + 1, onCompletion: onCompletion)
                return Single.just(result)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { _ in },
                       onFailure: { error in PP.debug(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    private func resendMessages(messages: [Message], index: Int = 0, onCompletion:  @escaping () -> Void) {
        guard index < messages.count else {
            onCompletion()
            return
        }
        var message = messages[index]
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
            .subscribe(onSuccess: { [weak self] _ in
                self?.resendMessages(messages: messages, index: index + 1, onCompletion: onCompletion)
            }, onFailure: { error in PP.debug(error.localizedDescription)
            })
            .disposed(by: disposeBag)
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
