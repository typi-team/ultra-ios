import Foundation
import AVFAudio
import CallKit
import PushKit

public class UltraVoIPManager: NSObject {
    
    // MARK: - Properties
        
    private var deviceToken: String?
    
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
        let caller = try? Caller(dictionary: payload.dictionaryPayload)
        let callConfigObject = CXProviderConfiguration(localizedName: "Test")
        callConfigObject.supportsVideo = true
        let callReport = CXCallUpdate()
        if let sender = caller?.sender,
            let contact = AppSettingsImpl.shared.contactDBService.contact(id: sender) {
            callReport.remoteHandle = CXHandle(type: .generic, value: contact.displaName)
        }
        callReport.hasVideo = caller?.video ?? false
        let callProvider = CXProvider(configuration: callConfigObject)
        callProvider.reportNewIncomingCall(with: UUID(), update: callReport, completion: { error in })
        callProvider.setDelegate(self, queue: nil)
        if let caller {
            AppSettingsImpl.shared.updateRepository.handleIncoming(callRequest: caller)
        }
    }
    
}

extension UltraVoIPManager: CXProviderDelegate {
    
    public func providerDidReset(_ provider: CXProvider) {
        print("Did reset")
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("CXEndCallAction")
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("didActivate")
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("didDeactivate")
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        action.fulfill()
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
