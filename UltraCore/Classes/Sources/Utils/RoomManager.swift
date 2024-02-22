//
//  RoomManager.swift
//  UltraCore
//
//  Created by Typi on 20.02.2024.
//

import Foundation
import LiveKitClient

protocol RoomManagerDelegate: AnyObject {
    func didConnectToRoom()
    func didFailToConnectToRoom()
    func didDisconnectFromRoom()
}

final class RoomManager {
    
    lazy var room = Room()
    weak var roomManagerDelegate: RoomManagerDelegate?
    static let shared = RoomManager()
    private var callInfo: CallInformation?
    
    func addRoomDelegate(_ delegate: RoomDelegate) {
        room.add(delegate: delegate)
    }
    
    func removeRoomDelegate(_ delegate: RoomDelegate) {
        room.remove(delegate: delegate)
    }
    
    func connectRoom(with callInfo: CallInformation, completion: @escaping((Error?) -> Void)) {
        self.callInfo = callInfo
        room.connect(callInfo.host, callInfo.accessToken).then { [weak self] room in
            self?.roomManagerDelegate?.didConnectToRoom()
            completion(nil)
        }.catch { [weak self] error in
            PP.error("Error on connecting room - \(error.localizedDescription)")
            self?.roomManagerDelegate?.didFailToConnectToRoom()
            completion(error)
        }
    }
    
    func disconnectRoom() {
        room.disconnect().then { [weak self] _ in
            self?.callInfo = nil
            self?.roomManagerDelegate?.didDisconnectFromRoom()
        }.catch { error in
            PP.error("Error on disconnecting room - \(error.localizedDescription)")
        }
    }
    
    func disconnectRoom(for room: String) {
        PP.debug("[CALL] dismiss call for room - \(room)")
        guard callInfo?.room == room else {
            return
        }
        self.room.disconnect().then { [weak self] _ in
            self?.callInfo = nil
            self?.roomManagerDelegate?.didDisconnectFromRoom()
//            UltraVoIPManager.shared.endCall()
        }.catch { error in
            PP.error("Error on disconnecting room - \(error.localizedDescription)")
        }
    }
    
}
