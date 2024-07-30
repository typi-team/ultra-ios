//
//  AppSettingsImpl.swift
//  UltraCore
//
//  Created by Slam on 7/30/23.
//

import NIO
import GRPC
import UIKit
import RxSwift
import NIOPosix
import PodAsset
import Logging
import Realm
import RealmSwift

open class AppSettingsImpl: AppSettings  {
    
    static var shared = AppSettingsImpl()

//    MARK: Public properties

    lazy var serverConfig: ServerConfigurationProtocol = {
        return UltraCoreSettings.delegate?.serverConfig() ?? ServerConfiguration()
    }()

//    MARK: Local Singletone properties
    lazy var mediaUtils: MediaUtils = .init()
    lazy var podAsset = PodAsset.bundle(forPod: "UltraCore")
    lazy var version: String = podAsset?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.2"
    
    lazy var keepalive = ClientConnectionKeepalive()
    
    lazy var connectionBackoff = ConnectionBackoff()

    lazy var channel: GRPCChannel = try! GRPCChannelPool.with(
        target: .host(
            serverConfig.pathToServer,
            port: serverConfig.portOfServer
        ),
        transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()), 
        eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
    )
    lazy var fileChannel: GRPCChannel = try! GRPCChannelPool.with(
        target: .host(
            serverConfig.pathToServer,
            port: serverConfig.portOfServer
        ),
        transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()),
        eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
    )
    lazy var updateChannel: GRPCChannel = try! GRPCChannelPool.with(
        target: .host(
            serverConfig.pathToServer,
            port: serverConfig.portOfServer
        ),
        transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()),
        eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
    )

//    MARK: GRPC Services
    lazy var callService: CallServiceClientProtocol = CallServiceNIOClient(channel: channel)
    lazy var userService: UserServiceClientProtocol = UserServiceNIOClient(channel: channel)
    lazy var authService: AuthServiceClientProtocol = AuthServiceNIOClient(channel: channel)
    lazy var fileService: FileServiceClientProtocol = FileServiceNIOClient(channel: fileChannel)
    lazy var deviceService: DeviceServiceClientProtocol = DeviceServiceNIOClient(channel: channel)
    lazy var messageService: MessageServiceClientProtocol = MessageServiceNIOClient(channel: channel)
    lazy var contactsService: ContactServiceClientProtocol = ContactServiceNIOClient(channel: channel)
    lazy var updateService: UpdatesServiceClientProtocol = UpdatesServiceNIOClient(channel: updateChannel)
    lazy var conversationService: ChatServiceClientProtocol = ChatServiceNIOClient.init(channel: channel)
    lazy var integrateService: IntegrationServiceClientProtocol = IntegrationServiceNIOClient.init(channel: channel)
    lazy var supportService: SupportServiceClientProtocol = SupportServiceNIOClient(channel: channel)

//    MARK: Services

    lazy var appStore: AppSettingsStore = AppSettingsStoreImpl()
    lazy var messageDBService: MessageDBService = .init(appStore: appStore)
    lazy var contactDBService: ContactDBService = .init(appStore: appStore)
    lazy var conversationDBService: ConversationDBService = .init(appStore: appStore)

//    MARK: Repositories

    lazy var voiceRepository: VoiceRepository = VoiceRepository.init(mediaUtils: mediaUtils)
    lazy var mediaRepository: MediaRepository = MediaRepositoryImpl(mediaUtils: mediaUtils,
                                                                    uploadFileInteractor: UploadFileInteractor(),
                                                                    createFileSpaceInteractor: CreateFileInteractor())
    lazy var contactRepository: ContactsRepository = ContactsRepositoryImpl(contactDBService: contactDBService)
    lazy var messageRespository: MessageRepository = MessageRespositoryImpl(messageService: messageDBService)
    lazy var updateRepository: UpdateRepository = UpdateRepositoryImpl.init(
        appStore: appStore,
        messageService: messageDBService,
        contactService: contactDBService,
        conversationService: conversationDBService,
        pingPongInteractorImpl: PingPongInteractorImpl.init(),
        userByIDInteractor: ContactByUserIdInteractor.init(
            delegate: UltraCoreSettings.delegate
        ),
        retrieveContactStatusesInteractorImpl: RetrieveContactStatusesInteractor(
            contactDBService: contactDBService),
        updateContactStatusInteractor: UpdateContactStatusInteractor(
            contactDBService: contactDBService),
        deliveredMessageInteractor: DeliveredMessageInteractor.init(),
        chatInteractor: ConversationInteractor(),
        initSupportInteractor: InitSupportChatsInteractor(),
        chatToConversationInteractor: ChatToConversationInteractor(
            contactByUserIdInteractor: ContactByUserIdInteractor.init(
                delegate: UltraCoreSettings.delegate
            ),
            contactDBService: contactDBService
        )
    )
    lazy var conversationRespository: ConversationRepository = ConversationRepositoryImpl(conversationService: conversationDBService)
    
    //    MARK: App main interactors, must be create once
    
    lazy var updateTokenInteractor: UseCase<Void, Void> = UpdateTokenInteractorImpl.init(appStore: appStore)
    lazy var superMessageSaverInteractor: UseCase<MessageData, Conversation?> = SuperMessageSaverInteractor.init(
        appStore: appStore,
        contactDBService: contactDBService,
        messageDBService: messageDBService,
        conversationDBService: conversationDBService)
    
    init() {
        PP.initialize()
    }
    
    func recreate() {
        channel = try! GRPCChannelPool.with(
            target: .host(
                serverConfig.pathToServer,
                port: serverConfig.portOfServer
            ),
            transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()),
            eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
        )
        fileChannel = try! GRPCChannelPool.with(
            target: .host(
                serverConfig.pathToServer,
                port: serverConfig.portOfServer
            ),
            transportSecurity: .tls(
                .makeClientConfigurationBackedByNIOSSL()),
            eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
        )
        updateChannel = try! GRPCChannelPool.with(
            target: .host(
                serverConfig.pathToServer,
                port: serverConfig.portOfServer),
            transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()),
            eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
        )
        callService = CallServiceNIOClient(channel: channel)
        userService = UserServiceNIOClient(channel: channel)
        authService = AuthServiceNIOClient(channel: channel)
        fileService = FileServiceNIOClient(channel: fileChannel)
        deviceService = DeviceServiceNIOClient(channel: channel)
        messageService = MessageServiceNIOClient(channel: channel)
        contactsService = ContactServiceNIOClient(channel: channel)
        updateService = UpdatesServiceNIOClient(channel: updateChannel)
        conversationService = ChatServiceNIOClient.init(channel: channel)
        integrateService = IntegrationServiceNIOClient.init(channel: channel)
        supportService = SupportServiceNIOClient(channel: channel)
        UltraCoreSettings.updateSession(callback: { _ in })
    }
    
    func logout() {
        Realm.realmQueue.async {
            let realm = Realm.myRealm()
            try? realm.write({
                realm.deleteAll()
            })
        }
        self.appStore.deleteAll()
    }
    
    private func setupChannelConfiguration(configuration: inout GRPCChannelPool.Configuration) {
        configuration.keepalive = keepalive
        configuration.connectionBackoff = connectionBackoff
        configuration.idleTimeout = TimeAmount.seconds(60)
    }
}

