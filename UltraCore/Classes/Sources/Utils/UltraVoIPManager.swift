import Foundation
import AVFAudio
import CallKit
import PushKit
import RxSwift
import UIKit

public class UltraVoIPManager: NSObject {
    
    // MARK: - Properties
        
    private var deviceToken: String? {
        didSet {
            guard let deviceToken = deviceToken else {
                return
            }
            UltraCoreSettings.delegate?.didUpdateVoipToken(deviceToken)
        }
    }
    
    private var callInfoMeta: CallMetadata? {
        didSet {
            PP.debug("[CALL] Setting callinfometa - \(callInfoMeta?.callInfo.room)")
        }
    }
    
    private let callController = CXCallController()
    
    private var provider: CXProvider
    
    private lazy var callRejectInteractor: GRPCErrorUseCase<CallerRequestParams, Void> = RejectCallInteractor(callService: AppSettingsImpl.shared.callService)
    private lazy var callCancelInteractor: GRPCErrorUseCase<CallerRequestParams, Void> = CancelCallInteractor(callService: AppSettingsImpl.shared.callService)
    private lazy var endCallInteractor: GRPCErrorUseCase<EndCallParams, Void> = EndCallInteractor(callService: AppSettingsImpl.shared.callService)
    private let callDBService = CallDBService()
    private let disposeBag = DisposeBag()
    private var callStatusSubscription: Disposable?
    private var callStatusEnum: CallStatusEnum?
        
    public static let shared = UltraVoIPManager()
    
    private var wasAnswered: Bool = false
        
    public var token: String? {
        deviceToken
    }
    
    // MARK: - Init
    
    override init() {
        let callConfigObject = CXProviderConfiguration(localizedName: NSLocalizedString("app.name", comment: ""))
        callConfigObject.supportsVideo = true
        callConfigObject.maximumCallsPerCallGroup = 1
        callConfigObject.supportedHandleTypes = [.generic]
        if let icon = UltraCoreSettings.delegate?.callImage() {
            callConfigObject.iconTemplateImageData = icon.pngData()
        } else if let icon = UIImage.named("tradernet_call_icon") {
            callConfigObject.iconTemplateImageData = icon.pngData()
        }
        self.provider = CXProvider(configuration: callConfigObject)
        super.init()
        self.provider.setDelegate(self, queue: nil)
    }
    
    // MARK: - Methods
    
    @discardableResult
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        voipRegistration()
        return true
    }

    private func voipRegistration() {
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
}

// MARK: - PKPushRegistryDelegate

extension UltraVoIPManager: PKPushRegistryDelegate {
    
    public func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
    }
    
    public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        do {
            let caller = try Caller(dictionary: payload.dictionaryPayload)
            PP.debug("[CALL] Got VOIP Push - \(caller.room), video - \(caller.video)")
            let callReport = CXCallUpdate()
            callReport.hasVideo = caller.video
            if let contact = AppSettingsImpl.shared.contactDBService.contact(id: caller.sender) {
                callReport.remoteHandle = CXHandle(type: .generic, value: contact.displaName)
            }
            if callInfoMeta == nil {
                UltraCoreSettings.updateSession { _ in }
                let uuid = UUID()
                provider.reportNewIncomingCall(with: uuid, update: callReport, completion: { error in
                    completion()
                })
                callInfoMeta = CallMetadata(callInfo: caller, uuid: uuid, isOutgoing: false)
                subscribeToCall()
            }
        }
        catch {
            PP.error("Error on receiving VOIP push - \(error.localizedDescription)")
            completion()
        }
    }
    
    private func presentIncomingCall() {
        guard let callInfoMeta else { return }
        if let topController = UIApplication.topViewController(), !(topController is IncomingCallViewController) {
            topController.presentWireframe(IncomingCallWireframe(call: .incoming(callInfoMeta.callInfo)))
        }
    }
    
}

extension UltraVoIPManager: CXProviderDelegate {
    
    public func providerDidReset(_ provider: CXProvider) {
        print("[CALL] Did reset")
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        PP.debug("[CALL] CXAnswerCallAction CXProviderDelegate")
        guard let callInfoMeta, action.callUUID == callInfoMeta.uuid else {
            action.fail()
            return
        }
        wasAnswered = true
        configureAudioSession()
        action.fulfill()
        PP.debug("[CALL] CXAnswerCallAction CXProviderDelegate for uuid - \(callInfoMeta.uuid)")
        if let topController = UIApplication.topViewController(), !(topController is IncomingCallViewController) {
            topController.presentWireframe(
                IncomingCallWireframe(call: .incoming(callInfoMeta.callInfo)),
                animated: true) {
                    RoomManager.shared.connectRoom(with: callInfoMeta.callInfo) { error in
                        if let error = error {
                            PP.debug("Error on connecting room - \(callInfoMeta.callInfo.room) \(error)")
                        }
                    }
                }
        } else {
            RoomManager.shared.connectRoom(with: callInfoMeta.callInfo) { error in
                if let error = error {
                    PP.debug("Error on connecting room - \(callInfoMeta.callInfo.room) \(error)")
                }
            }
        }
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        PP.debug("[CALL] CXEndCallAction CXProviderDelegate")
        guard let callInfoMeta else {
            action.fail()
            return
        }
        cancelCallStatusSubscription()
        PP.debug("[CALL] CXEndCallAction CXProviderDelegate for uuid - \(callInfoMeta.uuid)")
//        guard !callInfoMeta.isOutgoing else {
//            RoomManager.shared.disconnectRoom()
//            action.fulfill()
//            return
//        }
        action.fulfill()
        guard let callStatusEnum else {
            return
        }
        
        let completion: (Error?) -> Void = { [weak self] error in
            if let error = error {
                PP.debug("[CALL] CXEndCallAction for uuid - \(callInfoMeta.uuid) error - \(error)")
            } else {
                self?.callInfoMeta = nil
                self?.callStatusEnum = nil
                PP.debug("[CALL] CXEndCallAction for uuid - \(callInfoMeta.uuid) fulfilled")
            }
        }
        
        switch callStatusEnum {
        case .callStatusCreated:
            if callInfoMeta.isOutgoing {
                cancelCall(callInfo: callInfoMeta.callInfo, completion: completion)
            } else {
                rejectCall(callInfo: callInfoMeta.callInfo, completion: completion)
            }
        case .callStatusStarted:
            endCall(callInfo: callInfoMeta.callInfo, completion: completion)
        case .callStatusCanceled:
            completion(nil)
        case .callStatusMissed:
            completion(nil)
        case .callStatusRejected:
            completion(nil)
        case .callStatusEnded:
            completion(nil)
        case .UNRECOGNIZED(let int):
            break
        }
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        PP.debug("[CALL] CXSetMutedCallAction")
        currentCallingController?.setMicrophoneIfPossible(enabled: !action.isMuted)
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        PP.debug("[CALL] CXStartCallAction")
        guard let callInfoMeta, callInfoMeta.uuid == action.callUUID else {
            PP.debug("[CALL] CXStartCallAction failed")
            action.fail()
            return
        }
        wasAnswered = false
        configureAudioSession()
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
        action.fulfill()
        RoomManager.shared.connectRoom(with: callInfoMeta.callInfo) { [weak self] error in
            if let error = error {
                PP.debug("[CALL] server CXStartCallAction error - \(error)")
            } else {
                self?.provider.reportOutgoingCall(with: action.callUUID, connectedAt: nil)
            }
        }
    }
    
    private var currentCallingController: IncomingCallViewController? {
        if let topController = UIApplication.topViewController(),
            let incomingCall = topController as? IncomingCallViewController {
            return incomingCall
        }
        return nil
    }
    
    func startOutgoingCall(callInfo: CallInformation) {
        let uuid = UUID()
        self.callInfoMeta = CallMetadata(callInfo: callInfo, uuid: uuid, isOutgoing: true)
        let handleValue = AppSettingsImpl.shared.contactDBService.contact(id: callInfo.sender)?.displaName ?? "Unknown"
        let handle = CXHandle(type: .generic, value: handleValue)
        PP.debug("[CALL] Starting outgoing call - \(callInfo.room)")
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = callInfo.video
        let transaction = CXTransaction(action: startCallAction)
        callController.request(transaction) { [weak self] error in
            if let error = error {
                PP.debug("[CALL] Starting outgoing call error - \(error)")
            } else {
                PP.debug("[CALL] Request transaction for starting outgoing call is successful")
                DispatchQueue.main.async {
                    self?.subscribeToCall()
                }
            }
        }
        
    }
    
    func reportOutgoingCall() {
        guard let callInfoMeta = callInfoMeta else {
            return
        }
        provider.reportOutgoingCall(with: callInfoMeta.uuid, connectedAt: nil)
    }
    
    func endCall() {
        PP.debug("[CALL] CXEndCallAction")
        guard let uuid = callInfoMeta?.uuid else { return }
        PP.debug("[CALL] CXEndCallAction for uuid - \(uuid)")
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction) { error in
            if let error = error {
                PP.debug("[CALL] CXEndCallAction error - \(error)")
            } else {
                PP.debug("[CALL] Request transaction for ending call is successful")
            }
        }
    }
    
    func serverEndCall() {
        PP.debug("[CALL] server CXEndCallAction")
        guard let uuid = callInfoMeta?.uuid else { return }
        PP.debug("[CALL] server CXEndCallAction for uuid - \(uuid)")
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction) { error in
            RoomManager.shared.disconnectRoom()
            DispatchQueue.main.async {
                IncomingCallTopView.hide { }
                if UIApplication.shared.applicationState != .active {
                    UltraCoreSettings.stopSession()
                }
            }
            if let error = error {
                PP.debug("[CALL] server CXEndCallAction error - \(error)")
            } else {
                PP.debug("[CALL] server Request transaction for ending call is successful")
            }
        }
    }
    
    func answerCall() {
        PP.debug("[CALL] CXAnswerCallAction")
        guard let uuid = callInfoMeta?.uuid else { return }
        PP.debug("[CALL] CXAnswerCallAction for uuid - \(uuid)")
        let answerCallAction = CXAnswerCallAction(call: uuid)
        let transaction = CXTransaction(action: answerCallAction)
        callController.request(transaction, completion: { error in
            if let error = error {
                PP.debug("[CALL] CXAnswerCallAction error - \(error)")
            }
        })
    }
    
    private func cancelCall(callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        PP.debug("[CALL] - Cancell call - \(callInfo.room)")
        callCancelInteractor
            .executeSingle(params: .init(userID: callInfo.sender, room: callInfo.room))
            .subscribe { _ in
                RoomManager.shared.disconnectRoom()
                DispatchQueue.main.async {
                    IncomingCallTopView.hide { }
                }
                completion(nil)
            } onFailure: { error in
                completion(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func rejectCall(callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        PP.debug("[CALL] - Reject call - \(callInfo.room)")
        callRejectInteractor
            .executeSingle(params: .init(userID: callInfo.sender, room: callInfo.room))
            .subscribe { _ in
                DispatchQueue.main.async {
                    IncomingCallTopView.hide { }
                }
                completion(nil)
            } onFailure: { error in
                completion(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func endCall(callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        PP.debug("[CALL] - End call - \(callInfo.room)")
        endCallInteractor
            .executeSingle(params: .init(room: callInfo.room))
            .subscribe { _ in
                RoomManager.shared.disconnectRoom()
                DispatchQueue.main.async {
                    IncomingCallTopView.hide { }
                }
                completion(nil)
            } onFailure: { error in
                completion(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureAudioSession() {
        guard let callInfoMeta else {
            return
        }
        PP.debug("[CALL] Configure audio session isVideo - \(callInfoMeta.callInfo.video)")
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [
                    .allowBluetooth, .allowBluetoothA2DP, .duckOthers
                ]
            )
            try session.setPreferredIOBufferDuration(0.005)
            try session.setPreferredSampleRate(44100)
            try session.overrideOutputAudioPort(.none)
            try session.setActive(true)
        } catch {
            PP.debug("[CALL] Error on configuring audio session - \(error)")
        }
    }
    
    func subscribeToCall() {
        guard let callInfoMeta else {
            return
        }
        callStatusSubscription = callDBService.callUpdates(for: callInfoMeta.callInfo.room)
            .debug("[CALL UPDATE]")
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] callStatus in
                self?.callStatusEnum = callStatus
                if callStatus.shouldFinish {
                    self?.serverEndCall()
                }
            } onError: { error in
                
            }
    }
    
    func cancelCallStatusSubscription() {
        callStatusSubscription?.dispose()
    }
    
    func showCallTopView() {
        DispatchQueue.main.async {
            IncomingCallTopView.show { [unowned self] in
                guard let callInfoMeta = self.callInfoMeta else {
                    return
                }
                
                let callStatus: CallStatus = callInfoMeta.isOutgoing ? .outcoming(callInfoMeta.callInfo) : .incoming(callInfoMeta.callInfo)
                IncomingCallTopView.hide {
                    if let topController = UIApplication.topViewController(), !(topController is IncomingCallViewController) {
                        topController.presentWireframe(IncomingCallWireframe(call: callStatus))
                    }
                }
            }
        }
    }
    
    @objc func didTapCall() {
        guard let callInfoMeta else {
            return
        }
        
        let callStatus: CallStatus = callInfoMeta.isOutgoing ? .outcoming(callInfoMeta.callInfo) : .incoming(callInfoMeta.callInfo)
        
        if let topController = UIApplication.topViewController(), !(topController is IncomingCallViewController) {
            topController.presentWireframeWithNavigation(IncomingCallWireframe(call: callStatus), animated: true)
        }
    }
    
}

extension UltraVoIPManager {
    
    struct Caller: Codable, CallInformation {
        var sender: String
        var access_token: String
        var room: String
        var host: String
        var video: Bool
        
        var accessToken: String {
            get {
                access_token
            }
            set {
                access_token = newValue
            }
        }
        
        init(dictionary: [AnyHashable: Any]) throws {
            self = try JSONDecoder().decode(Caller.self, from: JSONSerialization.data(withJSONObject: dictionary))
        }
    }
    
    struct CallMetadata {
        let callInfo: CallInformation
        let uuid: UUID
        let isOutgoing: Bool
    }
    
}

fileprivate extension CallStatusEnum {
    var shouldFinish: Bool {
        switch self {
        case .callStatusCanceled, .callStatusEnded, .callStatusMissed, .callStatusRejected:
            return true
        default:
            return false
        }
    }
}
