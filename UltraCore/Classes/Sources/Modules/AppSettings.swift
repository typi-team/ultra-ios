import NIO
import GRPC
import UIKit
import NIOPosix
import PodAsset

protocol AppSettings: Any {
    var channel: GRPCChannel { get }
    var group: EventLoopGroup { get set }
    var authService: AuthServiceClientProtocol { get }
}

open class AppSettingsImpl:AppSettings  {

    static let shared = AppSettingsImpl()

//    MARK: Public properties

    public var portOfServer: Int = 8080
    public var pathToServer: String = "ultra-dev.typi.team"

//    MARK: Local Singletone properties

    lazy var podAsset = PodAsset.bundle(forPod: "UltraCore")
    lazy var group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    lazy var version: String = podAsset?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.2"
    lazy var channel: GRPCChannel = try! GRPCChannelPool.with(target: .host(pathToServer, port: portOfServer),
                                                              transportSecurity: .plaintext, eventLoopGroup: group)

//    MARK: Services

    lazy var authService: AuthServiceClientProtocol = AuthServiceNIOClient(channel: self.channel)
}


public func showSignUp(view controller: UIViewController) {
    let wireframe = SignUpWireframe.init()
    wireframe.start(presentation: controller)
}
