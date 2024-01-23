//
//  IncomingCallInterfaces.swift
//  Pods
//
//  Created by Slam on 9/4/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

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
    func disconnectRoom() 
    func dispay(view contact: ContactDisplayable)
}



protocol IncomingCallPresenterInterface: PresenterInterface {
    func viewDidLoad()
    func getCallStatus() -> CallStatus
    func reject()
    func cancel()
}
