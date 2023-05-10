import NIO
import GRPC
import UIKit
import NIOPosix
import PodAsset

protocol AppSettings: Any {
    var channel: GRPCChannel { get }
    var group: EventLoopGroup { get set }
    var appStore: AppSettingsStore { get set }
    var messageRespository: MessageRepository { get }
    var contactRepository: ContactsRepository { get }
    var authService: AuthServiceClientProtocol { get }
    var messageService: MessageServiceClientProtocol { get }
    var contactsService: ContactServiceClientProtocol { get }
    var conversationRespository: ConversationRepository { get }
    
    var updateRepository: UpdateRepository { get }
}

open class AppSettingsImpl:AppSettings  {
    static let shared = AppSettingsImpl()

//    MARK: Public properties

    public var portOfServer: Int = 8080
    public var pathToServer: String = "ultra-dev.typi.team"

//    MARK: Local Singletone properties

    lazy var podAsset = PodAsset.bundle(forPod: "UltraCore")
    lazy var group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    lazy var version: String = podAsset?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.2"
    lazy var channel: GRPCChannel = try! GRPCChannelPool.with(target: .host(pathToServer, port: portOfServer),
                                                              transportSecurity: .plaintext, eventLoopGroup: group)

//    MARK: GRPC Services
    
    lazy var authService: AuthServiceClientProtocol = AuthServiceNIOClient(channel: channel)
    lazy var updateService: UpdatesServiceClientProtocol = UpdatesServiceNIOClient(channel: channel)
    lazy var messageService: MessageServiceClientProtocol = MessageServiceNIOClient(channel: channel)
    lazy var contactsService: ContactServiceClientProtocol = ContactServiceNIOClient(channel: channel)

//    MARK: Services

    lazy var messageDBService: MessageDBService = .init(userId: appStore.userID())
    lazy var appStore: AppSettingsStore = AppSettingsStoreImpl()
    lazy var contactDBService: ContactDBService = .init(userID: appStore.userID())
    lazy var conversationDBService: ConversationDBService = .init(userID: appStore.userID())

//    MARK: Repositories

    lazy var contactRepository: ContactsRepository = ContactsRepositoryImpl(contactDBService: contactDBService)
    lazy var messageRespository: MessageRepository = MessageRespositoryImpl(messageService: messageDBService)
    lazy var updateRepository: UpdateRepository = UpdateRepositoryImpl.init(messageService: messageDBService,
                                                                            contactService: contactDBService,
                                                                            update: updateService,
                                                                            userByIDInteractor: ContactByUserIdInteractor.init(contactsService: contactsService),
                                                                            conversationService: conversationDBService)
    lazy var conversationRespository: ConversationRepository = ConversationRepositoryImpl(conversationService: conversationDBService)
}

public func showSignUp(view controller: UIViewController) {
    
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
    UIBarButtonItem.appearance().title = ""
    
    
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: UIControlState.highlighted)

    
    if AppSettingsImpl.shared.appStore.isAuthed {
        let wireframe = ConversationsWireframe()
        wireframe.presentWithNavigation(presentation: controller)
    } else {
        let wireframe = SignUpWireframe.init()
        wireframe.start(presentation: controller)
    }
}
