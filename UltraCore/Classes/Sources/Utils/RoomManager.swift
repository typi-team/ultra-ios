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
    
    func addRoomDelegate(_ delegate: RoomDelegate) {
        room.add(delegate: delegate)
    }
    
    func removeRoomDelegate(_ delegate: RoomDelegate) {
        room.remove(delegate: delegate)
    }
    
    func connectRoom(with callInfo: CallInformation) {
        room.connect(callInfo.host, callInfo.accessToken).then { [weak self] room in
            self?.roomManagerDelegate?.didConnectToRoom()
        }.catch { error in
            PP.error("Error on connecting room - \(error.localizedDescription)")
        }
    }
    
    func disconnectRoom() {
        room.disconnect().then { [weak self] _ in
            self?.roomManagerDelegate?.didDisconnectFromRoom()
        }.catch { error in
            PP.error("Error on disconnecting room - \(error.localizedDescription)")
        }
    }
    
}
