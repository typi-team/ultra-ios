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

//    MARK: Services
    lazy var appStore: AppSettingsStore = AppSettingsStoreImpl()
    lazy var contactRepository: ContactsRepository = ContactsRepositoryImpl()
    lazy var messageRespository: MessageRepository = MessageRespositoryImpl()
    lazy var authService: AuthServiceClientProtocol = AuthServiceNIOClient(channel: self.channel)
    lazy var messageService: MessageServiceClientProtocol = MessageServiceNIOClient.init(channel: channel)
    lazy var contactsService: ContactServiceClientProtocol = ContactServiceNIOClient(channel: self.channel)
    
}

public func showSignUp(view controller: UIViewController) {
    
    if AppSettingsImpl.shared.appStore.isAuthed {
        let wireframe = ConversationsWireframe()
        wireframe.presentWithNavigation(presentation: controller)
    } else {
        let wireframe = SignUpWireframe.init()
        wireframe.start(presentation: controller)
    }
}
