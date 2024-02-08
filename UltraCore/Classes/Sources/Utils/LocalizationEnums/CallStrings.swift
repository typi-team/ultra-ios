//
//  CallStrings.swift
//  UltraCore
//
//  Created by Slam on 9/5/23.
//

import Foundation
enum CallStrings: String {
    case disconnected
    case connecting
    case reconnecting
    case connected
    case cancel
    case reject
    case incomeAudioCalling
    case incomeVideoCalling
    case errorAccessTitle
    case errorAccessToCamera
    case errorAccessToMicrophone
}

extension CallStrings: StringLocalizable {
    var prefixOfTemplate: String { "call" }
    var localizableValue: String { rawValue }
}



