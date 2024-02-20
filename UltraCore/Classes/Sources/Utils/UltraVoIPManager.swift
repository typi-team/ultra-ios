import Foundation
import AVFAudio
import CallKit
import PushKit

public class UltraVoIPManager: NSObject {
    
    // MARK: - Properties
        
    private var deviceToken: String?
    
    private var callInfoMeta: (callInfo: CallInformation, uuid: UUID)?
    
    private let callController = CXCallController()
    
    private var provider: CXProvider
    
    private let callService: CallServiceClientProtocol
        
    public static let shared = UltraVoIPManager(callService: AppSettingsImpl.shared.callService)
        
    public var token: String? {
        deviceToken
    }
    
    // MARK: - Init
    
    init(callService: CallServiceClientProtocol) {
        self.callService = callService
        let callConfigObject = CXProviderConfiguration(localizedName: "Ultra")
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
                callInfoMeta = (caller, uuid)
            }
        }
        catch {
            PP.error("Error on receiving VOIP push - \(error.localizedDescription)")
        }
    }
    
    private func presentIncomingCall() {
        guard let callInfoMeta else { return }
        if let topController = UIApplication.topViewController(), !(topController is IncomingCallViewController) {
            topController.presentWireframeWithNavigation(IncomingCallWireframe(call: .incoming(callInfoMeta.callInfo)))
        }
    }
    
}

extension UltraVoIPManager: CXProviderDelegate {
    
    public func providerDidReset(_ provider: CXProvider) {
        print("[CALL] Did reset")
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        PP.debug("[CALL] CXAnswerCallAction CXProviderDelegate")
        guard let callInfoMeta else { return }
        PP.debug("[CALL] CXAnswerCallAction CXProviderDelegate for uuid - \(callInfoMeta.uuid)")
        if let topController = UIApplication.topViewController(), !(topController is IncomingCallViewController) {
            topController.presentWireframeWithNavigation(
                IncomingCallWireframe(call: .incoming(callInfoMeta.callInfo)),
                animated: true) { [weak self] in
                    self?.currentCallingController?.answerToCall()
                    action.fulfill()
                }
        }
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        PP.debug("[CALL] CXEndCallAction CXProviderDelegate")
        guard let callInfoMeta else {
            return
        }
        PP.debug("[CALL] CXEndCallAction CXProviderDelegate for uuid - \(callInfoMeta.uuid)")
        callService.reject(
            RejectCallRequest.with({
                $0.room = callInfoMeta.callInfo.room
                $0.callerUserID = callInfoMeta.callInfo.sender
            }),
            callOptions: .default()
        )
        .response
        .whenComplete { [weak self] result in
            self?.callInfoMeta = nil
            action.fulfill()
        }
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        PP.debug("[CALL] set speaker true")
        currentCallingController?.setSpeaker(true)
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        PP.debug("[CALL] set speaker false")
        currentCallingController?.setSpeaker(false)
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        PP.debug("[CALL] CXSetMutedCallAction")
        currentCallingController?.setMicrophoneIfPossible(enabled: !action.isMuted)
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        PP.debug("[CALL] CXStartCallAction")
        action.fulfill()
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
        self.callInfoMeta = (callInfo, uuid)
        if let contact = AppSettingsImpl.shared.contactDBService.contact(id: callInfo.sender) {
            let handle = CXHandle(type: .generic, value: contact.displaName)
            PP.debug("[CALL] Starting outgoing call - \(uuid)")
            let startCallAction = CXStartCallAction(call: uuid, handle: handle)
            let transaction = CXTransaction(action: startCallAction)
            callController.request(transaction) { error in
                if let error = error {
                    PP.debug("[CALL] Starting outgoing call error - \(error)")
                }
            }
        }
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
            }
        }
        callInfoMeta = nil
    }
    
    func startCall() {
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
    
}
