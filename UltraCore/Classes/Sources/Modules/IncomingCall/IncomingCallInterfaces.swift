//
//  IncomingCallInterfaces.swift
//  Pods
//
//  Created by Slam on 9/4/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import LiveKitClient
import UIKit

protocol CallInformation {
    var sender: String { get set }
    var room: String { get set }
    var accessToken: String { get set }
    var host: String { get set }
    var video: Bool { get set }
}

extension CallRequest: CallInformation {}

struct CallOutging: CallInformation {
    var video: Bool
    var host: String
    var room: String
    var sender: String
    var accessToken: String
}

enum CallStatus {
    case incoming(CallInformation)
    case outcoming(CallInformation)
    
    var callInfo: CallInformation {
        switch self {
        case let .outcoming(callRequest),
             let .incoming(callRequest):
            return callRequest
        }
    }
}

protocol IncomingCallWireframeInterface: WireframeInterface {
}


protocol IncomingCallViewInterface: ViewInterface {
    func dispay(view contact: ContactDisplayable)
    func showConnectedRoom(with callStatus: CallStatus)
    func updateParticipantTrack(remote: RemoteParticipant?, local: LocalParticipant?)
    func updateForStartCall()
    func showConnectionStatus(_ status: String)
    func setCameraEnabled(_ enabled: Bool)
    func setMicEnabled(_ enabled: Bool)
}



protocol IncomingCallPresenterInterface: PresenterInterface {
    func viewDidLoad()
    func didTapBack()
    func answerCall()
    func getLocalParticipant() -> LocalParticipant?
    func getRemoteParticipant() -> RemoteParticipant?
    func getCallStatus() -> CallStatus
    func getIsConnected() -> Bool
    func reject()
    func cancel()
    func setMicrophone(enabled: Bool)
    func setCamera(enabled: Bool)
}
