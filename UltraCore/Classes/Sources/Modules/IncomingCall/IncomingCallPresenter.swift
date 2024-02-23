//
//  IncomingCallPresenter.swift
//  Pods
//
//  Created by Slam on 9/4/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import RxSwift
import LiveKitClient

final class IncomingCallPresenter {

    // MARK: - Private properties -
    
    fileprivate let callService: CallServiceClientProtocol
    
    fileprivate lazy var disposeBag: DisposeBag = .init()

    private unowned let view: IncomingCallViewInterface
    
    fileprivate let contactInteractor: ContactByUserIdInteractor
    fileprivate let contactService: ContactDBService
    fileprivate let userId: String
    
    private let wireframe: IncomingCallWireframeInterface
    fileprivate let callStatus: CallStatus
    // MARK: - Lifecycle -

    init(userId: String,
         callInformation: CallStatus,
         view: IncomingCallViewInterface,
         contactService: ContactDBService,
         callService: CallServiceClientProtocol,
         wireframe: IncomingCallWireframeInterface,
         contactInteractor: ContactByUserIdInteractor) {
        self.view = view
        self.userId = userId
        self.wireframe = wireframe
        self.callService = callService
        self.contactService = contactService
        self.callStatus = callInformation
        self.contactInteractor = contactInteractor
        RoomManager.shared.roomManagerDelegate = self
        RoomManager.shared.addRoomDelegate(self)
    }
    
    deinit {
        RoomManager.shared.roomManagerDelegate = nil
        RoomManager.shared.removeRoomDelegate(self)
    }
}

// MARK: - Extensions -

extension IncomingCallPresenter: IncomingCallPresenterInterface {
    
    func getLocalParticipant() -> LocalParticipant? {
        RoomManager.shared.room.localParticipant
    }
    
    func getRemoteParticipant() -> RemoteParticipant? {
        RoomManager.shared.room.remoteParticipants.first?.value
    }
    
    func getIsConnected() -> Bool {
        RoomManager.shared.room.connectionState == .connected
    }
    
    func getCallStatus() -> CallStatus {
        callStatus
    }
    
    func reject() {
        UltraVoIPManager.shared.endCall()
    }
    
    func cancel() {
        UltraVoIPManager.shared.endCall()
    }
    
    func answerCall() {
//        RoomManager.shared.connectRoom(with: callStatus.callInfo)
    }
    
    func viewDidLoad() {
        if case .outcoming = callStatus {
            UltraVoIPManager.shared.startOutgoingCall(callInfo: callStatus.callInfo)
        }
        if let contact = contactService.contact(id: callStatus.callInfo.sender) {
            self.view.dispay(view: contact)
        } else {
//            self.contactInteractor
//                .executeSingle(params: self.callStatus.callInfo.sender)
//                .flatMap({ self.contactService.save(contact: DBContact(from: $0, chatId: )).map({ $0 }) })
//                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
//                .subscribe(on: MainScheduler.asyncInstance)
//                .subscribe(onSuccess: { [weak self] contact in
//                    guard let `self` = self, let contact = self.contactService.contact(id: callStatus.callInfo.sender) else { return }
//                    self.view.dispay(view: contact)
//                })
//                .disposed(by: disposeBag)
        }
    }
    
    func setMicrophone(enabled: Bool) {
        PP.debug("[CALL] Set microphone enabled - \(enabled)")
        RoomManager.shared.room.localParticipant?.setMicrophone(enabled: enabled)
    }
    
    func setCamera(enabled: Bool) {
        PP.debug("[CALL] Set camera enabled - \(enabled)")
        RoomManager.shared.room.localParticipant?.setCamera(enabled: enabled)
    }
    
}

extension IncomingCallPresenter: RoomDelegate {
    
    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {
        PP.debug("[CALL] connection state - \(connectionState.desctiption) for room - \(room.sid ?? "")")
        switch connectionState {
        case .reconnecting, .connecting:
            DispatchQueue.main.async { [weak self] in
                self?.view.showConnectionStatus(connectionState.desctiption)
            }
        default:
            break
        }
    }
    
    func room(_ room: Room, participantDidJoin participant: RemoteParticipant) {
        PP.debug("[CALL] participant - \(participant.name) did join for room - \(room.sid ?? "")")
        view.updateForStartCall()
    }
    
    func room(_ room: Room, localParticipant: LocalParticipant, didPublish publication: LocalTrackPublication) {
        guard publication.track is VideoTrack else { return }
        updateParticipantTrack(for: room)
    }
 
    func room(_ room: Room, participant: RemoteParticipant, didSubscribe publication: RemoteTrackPublication, track: Track) {
        guard track is VideoTrack else { return }
        updateParticipantTrack(for: room)
    }
    
    func room(_ room: Room, participant: Participant, didUpdate publication: TrackPublication, muted: Bool) {
        guard publication.track is VideoTrack else { return }
        updateParticipantTrack(for: room)
    }
    
    private func updateParticipantTrack(for room: Room) {
        let remote = room.remoteParticipants.first?.value
        let local = room.localParticipant
        view.updateParticipantTrack(remote: remote, local: local)
    }

}

extension IncomingCallPresenter: RoomManagerDelegate {
    func didConnectToRoom() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.view.showConnectedRoom(with: self.callStatus)
        }
    }
    
    func didFailToConnectToRoom() {
        DispatchQueue.main.async { [weak self] in
            self?.wireframe.dissmiss { }
        }
    }
    
    func didDisconnectFromRoom() {
        DispatchQueue.main.async { [weak self] in
            self?.wireframe.dissmiss { }
        }
    }
}
