//
//  ServerConfig.swift
//  UltraCore_Example
//
//  Created by Slam on 12/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UltraCore

struct ServerConfigImpl: ServerConfigurationProtocol {
    var portOfServer: Int = 443
    var pathToServer: String = "ultra-dev.typi.team"
}
