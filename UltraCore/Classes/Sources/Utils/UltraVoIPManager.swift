import Foundation
import AVFAudio
import CallKit
import PushKit

public class UltraVoIPManager: NSObject {
    
    // MARK: - Properties
        
    private var deviceToken: String?
    
    private var callInformation: Caller?
    
    private let callController = CXCallController()
    
    private var provider: CXProvider?
        
    public static let shared = UltraVoIPManager()
        
    public var token: String? {
        deviceToken
    }
    
    // MARK: - Init
    
    private override init() { }
    
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
        var caller = try? Caller(dictionary: payload.dictionaryPayload)
        let callConfigObject = CXProviderConfiguration(localizedName: "Ultra")
        let callReport = CXCallUpdate()
        callReport.hasVideo = caller?.video ?? false
        if let sender = caller?.sender,
            let contact = AppSettingsImpl.shared.contactDBService.contact(id: sender) {
            callReport.remoteHandle = CXHandle(type: .generic, value: contact.displaName)
        }
        if callInformation == nil {
            let uuid = UUID()
            let callProvider = CXProvider(configuration: callConfigObject)
            callProvider.reportNewIncomingCall(with: uuid, update: callReport, completion: { error in })
            callProvider.setDelegate(self, queue: nil)
            provider = callProvider
            caller?.uuid = uuid
            callInformation = caller
            presentIncomingCall()
        }
    }
    
    private func presentIncomingCall() {
        guard let callInformation else { return }
        if let topController = UIApplication.topViewController(), !(topController is IncomingCallViewController) {
            topController.presentWireframeWithNavigation(IncomingCallWireframe(call: .incoming(callInformation)))
        }
    }
    
}

extension UltraVoIPManager: CXProviderDelegate {
    
    public func providerDidReset(_ provider: CXProvider) {
        print("Did reset")
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        currentCallingController?.answerToCall()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        callInformation = nil
        currentCallingController?.cancelCall()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        currentCallingController?.setSpeaker(true)
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        currentCallingController?.setSpeaker(false)
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        currentCallingController?.setMicrophoneIfPossible(enabled: !action.isMuted)
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        action.fulfill()
    }
    
    private var currentCallingController: IncomingCallViewController? {
        if let topController = UIApplication.topViewController(),
            let incomingCall = topController as? IncomingCallViewController {
            return incomingCall
        }
        return nil
    }
    
    func endCall() {
        guard let uuid = callInformation?.uuid else { return }
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction) { error in }
    }
    
    func startCall() {
        guard let uuid = callInformation?.uuid else { return }
        let answerCallAction = CXAnswerCallAction(call: uuid)
        let transaction = CXTransaction(action: answerCallAction)
        callController.request(transaction, completion: { error in })
    }
    
}

extension UltraVoIPManager {
    
    struct Caller: Codable, CallInformation {
        var sender: String
        var accessToken: String
        var room: String
        var host: String
        var video: Bool
        var uuid: UUID?
        init(dictionary: [AnyHashable: Any]) throws {
            self = try JSONDecoder().decode(Caller.self, from: JSONSerialization.data(withJSONObject: dictionary))
        }
    }
    
}
