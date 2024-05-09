//
//  RoomManager.swift
//  UltraCore
//
//  Created by Typi on 20.02.2024.
//

import Foundation
import LiveKitClient
import RxSwift

protocol RoomManagerDelegate: AnyObject {
    func didConnectToRoom()
    func didFailToConnectToRoom()
    func didDisconnectFromRoom()
}

final class RoomManager {
    
    private var callInfo: CallInformation?
    private var timerSubscription: Disposable?
    private var timerTextSubject: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    lazy var room = Room()
    weak var roomManagerDelegate: RoomManagerDelegate?
    static let shared = RoomManager()
    var timerTextObservable: Observable<String> {
        timerTextSubject.asObservable().share()
    }
    
    var currentTimerValue: String {
        return (try? timerTextSubject.value()) ?? ""
    }
    
    var timerIsRunning: Bool {
        return timerSubscription != nil
    }
    
    func addRoomDelegate(_ delegate: RoomDelegate) {
        room.add(delegate: delegate)
    }
    
    func removeRoomDelegate(_ delegate: RoomDelegate) {
        room.remove(delegate: delegate)
    }
    
    func connectRoom(with callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        self.callInfo = callInfo
        Task {
            do {
                try await room.connect(url: callInfo.host, token: callInfo.accessToken)
                roomManagerDelegate?.didConnectToRoom()
                completion(nil)
            } catch {
                PP.error("[CALL] Error on connecting room - \(error.localizedDescription)")
                roomManagerDelegate?.didFailToConnectToRoom()
                completion(error)
            }
        }
    }
    
    func disconnectRoom() {
        stopCallTimer()
        PP.debug("[CALL] Disconnecting room with state - \(room.connectionState.desctiption)")
        Task {
            await room.disconnect()
            callInfo = nil
            roomManagerDelegate?.didDisconnectFromRoom()
        }
    }
    
    func disconnectRoom(for room: String) {
        PP.debug("[CALL] dismiss call for room - \(room)")
        guard callInfo?.room == room else {
            return
        }
        stopCallTimer()
        Task {
            await self.room.disconnect()
            callInfo = nil
            roomManagerDelegate?.didDisconnectFromRoom()
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
