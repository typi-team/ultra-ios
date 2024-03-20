//
//  RoomManager.swift
//  UltraCore
//
//  Created by Typi on 20.02.2024.
//

import AVFoundation
import Foundation
import LiveKitClient
import RxSwift
import WebRTC

protocol RoomManagerDelegate: AnyObject {
    func didConnectToRoom()
    func didFailToConnectToRoom()
    func didDisconnectFromRoom()
}

extension DispatchQueue {
    static let roomManager = DispatchQueue(label: "RoomManager", qos: .default)
}

final class RoomManager: NSObject {
    
    private var callInfo: CallInformation?
    private var timerSubscription: Disposable?
    private var timerTextSubject: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    lazy var room = Room()
    weak var roomManagerDelegate: RoomManagerDelegate?
    static let shared = RoomManager()
    
    var callConnectCompletion: ((Error?) -> Void)?
    
    var timerTextObservable: Observable<String> {
        timerTextSubject.asObservable().share()
    }
    
    var currentTimerValue: String {
        return (try? timerTextSubject.value()) ?? ""
    }
    
    var timerIsRunning: Bool {
        return timerSubscription != nil
    }
    
    override init() {
        super.init()
        room.add(delegate: self)
        RTCAudioSession.sharedInstance().add(self)
        AudioManager.shared.customConfigureAudioSessionFunc = { newState, oldState in
            DispatchQueue.roomManager.async { [weak self] in
                guard let self = self else { return }

                // prepare config
                let configuration = RTCAudioSessionConfiguration.webRTC()
                var categoryOptions: AVAudioSession.CategoryOptions = []

                if newState.trackState == .remoteOnly && newState.preferSpeakerOutput {
                    configuration.category = AVAudioSession.Category.playback.rawValue
                    configuration.mode = AVAudioSession.Mode.spokenAudio.rawValue

                } else if [.localOnly, .localAndRemote].contains(newState.trackState) ||
                            (newState.trackState == .remoteOnly && !newState.preferSpeakerOutput) {

                    configuration.category = AVAudioSession.Category.playAndRecord.rawValue
                    
                    if newState.preferSpeakerOutput {
                        // use .videoChat if speakerOutput is preferred
                        configuration.mode = AVAudioSession.Mode.voiceChat.rawValue
                    } else {
                        // use .voiceChat if speakerOutput is not preferred
                        configuration.mode = AVAudioSession.Mode.voiceChat.rawValue
                    }
                    categoryOptions = [.allowBluetooth, .allowBluetoothA2DP, .duckOthers]
                } else {
                    configuration.category = AVAudioSession.Category.soloAmbient.rawValue
                    configuration.mode = AVAudioSession.Mode.default.rawValue
                }
                
                configuration.categoryOptions = categoryOptions

                var setActive: Bool?

                if newState.trackState != .none, oldState.trackState == .none {
                    // activate audio session when there is any local/remote audio track
                    setActive = true
                } else if newState.trackState == .none, oldState.trackState != .none {
                    // deactivate audio session when there are no more local/remote audio tracks
                    setActive = false
                }
                
                let session = RTCAudioSession.sharedInstance()
                session.lockForConfiguration()
                defer { session.unlockForConfiguration() }

                do {
                    if let setActive = setActive {
                        try session.setConfiguration(configuration, active: setActive)
                    } else {
                        try session.setConfiguration(configuration)
                    }

                } catch let error {
                    PP.error("Failed to configure audio session with error: \(error)")
                }
                
            }
        }
    }
    
    func addRoomDelegate(_ delegate: RoomDelegate) {
        room.add(delegate: delegate)
    }
    
    func removeRoomDelegate(_ delegate: RoomDelegate) {
        room.remove(delegate: delegate)
    }
    
    func connectRoom(with callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        self.callInfo = callInfo
        self.callConnectCompletion = completion
        AudioManager.shared.preferSpeakerOutput = callInfo.video
        room.connect(callInfo.host, callInfo.accessToken).then { [weak self] room in
            self?.roomManagerDelegate?.didConnectToRoom()
        }.catch { [weak self] error in
            PP.error("[CALL] Error on connecting room - \(error.localizedDescription)")
            self?.roomManagerDelegate?.didFailToConnectToRoom()
            completion(error)
        }
    }
    
    func disconnectRoom() {
        stopCallTimer()
        PP.debug("[CALL] Disconnecting room with state - \(room.connectionState.desctiption)")
        room.disconnect().then { [weak self] _ in
            self?.callInfo = nil
            self?.roomManagerDelegate?.didDisconnectFromRoom()
        }.catch { error in
            PP.error("[CALL] Error on disconnecting room - \(error.localizedDescription)")
        }
    }
    
    func disconnectRoom(for room: String) {
        PP.debug("[CALL] dismiss call for room - \(room)")
        guard callInfo?.room == room else {
            return
        }
        stopCallTimer()
        self.room.disconnect().then { [weak self] _ in
            self?.callInfo = nil
            self?.roomManagerDelegate?.didDisconnectFromRoom()
        }.catch { error in
            PP.error("[CALL] Error on disconnecting room - \(error.localizedDescription)")
        }
    }
    
    func startCallTimer() {
        let timer = Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
        timerSubscription = timer.subscribe { [weak self] seconds in
            let minutes: Int = (seconds / 60)
            let seconds: Int = seconds % 60
            let formatted = String(format: "%02d:%02d", minutes, seconds)
            self?.timerTextSubject.onNext(formatted)
        }
    }
    
    func stopCallTimer() {
        timerSubscription?.dispose()
        timerSubscription = nil
        timerTextSubject.onNext("")
    }
    
}

extension RoomManager: RTCAudioSessionDelegate {
    func audioSession(_ audioSession: RTCAudioSession, didSetActive active: Bool) {
        PP.debug("Audio Session did set active - \(active)")
    }
    func audioSessionDidBeginInterruption(_ session: RTCAudioSession) {
        PP.debug("Audio session did begin interruption")
    }
    func audioSessionDidEndInterruption(_ session: RTCAudioSession, shouldResumeSession: Bool) {
        PP.debug("Audio session did end interruption, should resume - \(shouldResumeSession)")
    }
    func audioSessionDidChangeRoute(_ session: RTCAudioSession, reason: AVAudioSession.RouteChangeReason, previousRoute: AVAudioSessionRouteDescription) {
        PP.debug("Audio session did change route; reason - \(reason)")
    }
    func audioSession(_ audioSession: RTCAudioSession, failedToSetActive active: Bool, error: Error) {
        PP.debug("Audio session failed to set active - \(error)")
    }
    func audioSession(_ audioSession: RTCAudioSession, audioUnitStartFailedWithError error: Error) {
        PP.debug("Audio session unit start failed with error - \(error)")
    }
}

extension RoomManager: RoomDelegate {
    func room(_ room: Room, didConnect isReconnect: Bool) {
        PP.debug("ROOM didConnect")
        guard !isReconnect else { return }
        callConnectCompletion?(nil)
    }
    func room(_ room: Room, didDisconnect error: Error?) {
        PP.debug("ROOM didDisconnect")
    }
    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {
        switch connectionState {
        case .connected:
            PP.debug("[ROOMManager] - did connect")
            callConnectCompletion?(nil)
        default:
            break
        }
    }
}
