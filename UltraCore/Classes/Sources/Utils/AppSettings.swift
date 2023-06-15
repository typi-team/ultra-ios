import NIO
import GRPC
import UIKit
import RxSwift
import NIOPosix
import PodAsset
import Logging

public protocol UCAppDelegate: AnyObject {
    func ssid() -> String?
    func signUpView() -> UIViewController?
}

protocol AppSettings: Any {
    
    var delegate: UCAppDelegate? { get set }
    var appStore: AppSettingsStore { get set }
    
    var mediaRepository: MediaRepository { get }
    var updateRepository: UpdateRepository { get }
    var messageRespository: MessageRepository { get }
    var contactRepository: ContactsRepository { get }
    var conversationRespository: ConversationRepository { get }
    
    var fileService: FileServiceClientProtocol { get }
    var authService: AuthServiceClientProtocol { get }
    var messageService: MessageServiceClientProtocol { get }
    var contactsService: ContactServiceClientProtocol { get }
    
    func update(ssid: String, callback: @escaping(IssueJwtResponse) -> Void)
}

open class AppSettingsImpl: AppSettings  {
    
    weak var delegate: UCAppDelegate?
    
    static let shared = AppSettingsImpl()

//    MARK: Public properties

    private var portOfServer: Int = 443
    private var pathToServer: String = "ultra-dev.typi.team"

//    MARK: Local Singletone properties
    lazy var mediaUtils: MediaUtils = .init()
    lazy var podAsset = PodAsset.bundle(forPod: "UltraCore")
    lazy var version: String = podAsset?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.2"
    
    lazy var channel: GRPCChannel = try! GRPCChannelPool.with(target: .host(pathToServer, port: portOfServer),
                                                              transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()), eventLoopGroup: PlatformSupport.makeEventLoopGroup(compatibleWith: .makeClientConfigurationBackedByNIOSSL(), loopCount: 1))

    lazy var fileChannel: GRPCChannel = try! GRPCChannelPool.with(target: .host(pathToServer, port: portOfServer),
                                                                  transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()), eventLoopGroup: PlatformSupport.makeEventLoopGroup(compatibleWith: .makeClientConfigurationBackedByNIOSSL(), loopCount: 1))

    lazy var updateChannel: GRPCChannel = try! GRPCChannelPool.with(target: .host(pathToServer, port: portOfServer),
                                                                    transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()), eventLoopGroup: PlatformSupport.makeEventLoopGroup(compatibleWith: .makeClientConfigurationBackedByNIOSSL(), loopCount: 1))

//    MARK: GRPC Services
    
    lazy var authService: AuthServiceClientProtocol = AuthServiceNIOClient(channel: channel)
    lazy var fileService: FileServiceClientProtocol = FileServiceNIOClient(channel: fileChannel)
    lazy var messageService: MessageServiceClientProtocol = MessageServiceNIOClient(channel: channel)
    lazy var contactsService: ContactServiceClientProtocol = ContactServiceNIOClient(channel: channel)
    lazy var updateService: UpdatesServiceClientProtocol = UpdatesServiceNIOClient(channel: updateChannel)

//    MARK: Services

    lazy var messageDBService: MessageDBService = .init(userId: appStore.userID())
    lazy var appStore: AppSettingsStore = AppSettingsStoreImpl()
    lazy var contactDBService: ContactDBService = .init(userID: appStore.userID())
    lazy var conversationDBService: ConversationDBService = .init(userID: appStore.userID())

//    MARK: Repositories

    lazy var mediaRepository: MediaRepository = MediaRepositoryImpl(mediaUtils: mediaUtils,
                                                                    uploadFileInteractor: UploadFileInteractor(fileService: fileService),
                                                                    fileService: fileService,
                                                                    createFileSpaceInteractor: CreateFileInteractor(fileService: fileService))
    lazy var contactRepository: ContactsRepository = ContactsRepositoryImpl(contactDBService: contactDBService)
    lazy var messageRespository: MessageRepository = MessageRespositoryImpl(messageService: messageDBService)
    lazy var updateRepository: UpdateRepository = UpdateRepositoryImpl.init(appStore: appStore,
                                                                            messageService: messageDBService,
                                                                            contactService: contactDBService,
                                                                            update: updateService,
                                                                            conversationService: conversationDBService,
                                                                            userByIDInteractor: ContactByUserIdInteractor.init(contactsService: contactsService),
                                                                            deliveredMessageInteractor: DeliveredMessageInteractor.init(messageService: messageService))
    lazy var conversationRespository: ConversationRepository = ConversationRepositoryImpl(conversationService: conversationDBService)
    
    func update(ssid: String, callback: @escaping (IssueJwtResponse) -> Void) {
        self.appStore.ssid = ssid
        let localService = JWTTokenInteractorImpl(authService: authService)

        _ = localService.executeSingle(params: .with({ $0.sessionID = ssid }))
            .do(onSuccess: { [weak self] response in
                guard let `self` = self else { return }
                self.appStore.store(token: response.token)
                self.appStore.store(userID: response.userID)
            })
            .do(onSuccess: { callback($0) })
            .asObservable()
            .flatMap({ _ in Observable<Int64>.interval(.seconds(240), scheduler: ConcurrentDispatchQueueScheduler(qos: .background)) })
            .flatMap({ _ -> Observable<IssueJwtResponse> in
                localService.executeSingle(params: .with({ $0.sessionID = ssid })).asObservable()
            })
            .do(onNext: { [weak self] response in
                self?.appStore.store(token: response.token)
            })
            .catch({ error -> Observable<IssueJwtResponse> in
                print(error.localizedDescription)
                return Observable.just(IssueJwtResponse())
            })
            .subscribe()
    }
}

public func entryViewController(delegate: UCAppDelegate) -> UIViewController {
    AppSettingsImpl.shared.delegate = delegate
    UIBarButtonItem.appearance().tintColor = .green500
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.defaultRegularHeadline]
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: UIControlState.highlighted)

    let controller = AppSettingsImpl.shared.appStore.ssid == nil ? delegate.signUpView() ?? SignUpWireframe().viewController : ConversationsWireframe().viewController
    controller.hidesBottomBarWhenPushed = false
    return controller
}

public func entryViewController(with ssid: String, callback: @escaping(UIViewController) -> Void) {
    AppSettingsImpl.shared.update(ssid: ssid, callback: { _ in
        DispatchQueue.main.async {
            callback(ConversationsWireframe().viewController)
        }
    })
    
}
