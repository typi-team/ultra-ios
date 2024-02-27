import Foundation
import AVFAudio
import CallKit
import PushKit
import UIKit

public class UltraVoIPManager: NSObject {
    
    // MARK: - Properties
        
    private var deviceToken: String?
    
    private var callInfoMeta: CallMetadata? {
        didSet {
            PP.debug("[CALL] Setting callinfometa - \(callInfoMeta?.callInfo.room)")
        }
    }
    
    private let callController = CXCallController()
    
    private var provider: CXProvider
    
    private let callService: CallServiceClientProtocol
        
    public static let shared = UltraVoIPManager(callService: AppSettingsImpl.shared.callService)
    
    private var wasAnswered: Bool = false
        
    public var token: String? {
        deviceToken
    }
    
    // MARK: - Init
    
    init(callService: CallServiceClientProtocol) {
        self.callService = callService
        let callConfigObject = CXProviderConfiguration(localizedName: "Ultra")
        callConfigObject.supportsVideo = true
        callConfigObject.maximumCallsPerCallGroup = 1
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
                let uuid = UUID()
                provider.reportNewIncomingCall(with: uuid, update: callReport, completion: { error in
                    completion()
                })
                callInfoMeta = CallMetadata(callInfo: caller, uuid: uuid, isOutgoing: false)
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
        PP.debug("[CALL] CXEndCallAction CXProviderDelegate for uuid - \(callInfoMeta.uuid)")
//        guard !callInfoMeta.isOutgoing else {
//            RoomManager.shared.disconnectRoom()
//            action.fulfill()
//            return
//        }
        action.fulfill()
        rejectOrCancelCall(callInfo: callInfoMeta.callInfo) { [weak self] error in
            self?.callInfoMeta = nil
            if let error = error {
                PP.debug("[CALL] CXEndCallAction for uuid - \(callInfoMeta.uuid) error - \(error)")
            } else {
                PP.debug("[CALL] CXEndCallAction for uuid - \(callInfoMeta.uuid) fulfilled")
            }
        }
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        PP.debug("[CALL] set speaker true")
        PP.debug("[CALL] AVAudioSession outputs - \(AVAudioSession.sharedInstance().currentRoute.outputs)")
        currentCallingController?.setSpeaker(true)
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        PP.debug("[CALL] set speaker false")
        PP.debug("[CALL] AVAudioSession outputs - \(AVAudioSession.sharedInstance().currentRoute.outputs)")
        currentCallingController?.setSpeaker(false)
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
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
        configureAudioSession()
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
        callController.request(transaction) { error in
            if let error = error {
                PP.debug("[CALL] Starting outgoing call error - \(error)")
            } else {
                PP.debug("[CALL] Request transaction for starting outgoing call is successful")
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
        callController.request(transaction) { [weak self] error in
            self?.callInfoMeta = nil
            RoomManager.shared.disconnectRoom()
            DispatchQueue.main.async {
                IncomingCallTopView.hide { }
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
    
    private func rejectOrCancelCall(callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        if wasAnswered || callInfoMeta?.isOutgoing == .some(true) {
            cancelCall(callInfo: callInfo, completion: completion)
        } else {
            rejectCall(callInfo: callInfo, completion: completion)
        }
    }
    
    private func cancelCall(callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        PP.debug("[CALL] - Cancell call - \(callInfo.room)")
        callService.cancel(
            CancelCallRequest.with({
                $0.userID = callInfo.sender
                $0.room = callInfo.room
            }), callOptions: .default()
        )
        .response
        .whenComplete { result in
            switch result {
            case .success:
                RoomManager.shared.disconnectRoom()
                DispatchQueue.main.async {
                    IncomingCallTopView.hide { }
                }
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private func rejectCall(callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        PP.debug("[CALL] - Reject call - \(callInfo.room)")
        callService.reject(
            RejectCallRequest.with({
                $0.room = callInfo.room
                $0.callerUserID = callInfo.sender
            }),
            callOptions: .default()
        )
        .response
        .whenComplete { result in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
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
                options: callInfoMeta.callInfo.video ? [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP] : [.duckOthers, .allowBluetooth, .allowBluetoothA2DP]
            )
        } catch {
            PP.debug("[CALL] Error on configuring audio session - \(error)")
        }
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
//        let height: CGFloat = topInsets()
//        let frame = CGRect(origin: .zero, size: .init(width: UIScreen.main.bounds.size.width, height: height))
//        let callWindow = UIWindow(frame: frame)
//        if let windowLevel = UIApplication.shared.keyWindow?.windowLevel {
//            callWindow.windowLevel = windowLevel + 1
//        } else {
//            callWindow.windowLevel = UIWindow.Level(0)
//        }
//        callWindow.isHidden = false
//        let view = UIView(frame: frame)
//        view.backgroundColor = .green500
//        view.clipsToBounds = true
//        let label = UILabel(frame: .init(x: 0, y: height - 24, width: frame.width, height: 24))
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 15)
//        label.textColor = .white
//        label.text = "Touch to return to the call"
//        view.addSubview(label)
//        let button = UIButton(frame: frame)
//        button.addTarget(self, action: #selector(didTapCall), for: .touchUpInside)
//        view.addSubview(button)
//        callWindow.addSubview(view)
//        callWindow.transform = CGAffineTransform(translationX: 0, y: -height)
//        UIView.animate(withDuration: 0.3) {
//            callWindow.transform = CGAffineTransformIdentity
//            if let keyWindow = UIApplication.shared.keyWindow {
//                keyWindow.frame = CGRect(origin: .init(x: 0, y: height - 40), size: .init(width: keyWindow.bounds.size.width, height: keyWindow.bounds.size.height - height + 40))
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            UIView.animate(withDuration: 0.3) {
//                callWindow.transform = CGAffineTransform(translationX: 0, y: -height)
//                if let keyWindow = UIApplication.shared.keyWindow {
//                    keyWindow.frame = UIScreen.main.bounds
//                }
//            } completion: { _ in
//                callWindow.isHidden = true
//            }
//        }
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
        var accessToken: String
        var room: String
        var host: String
        var video: Bool
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
