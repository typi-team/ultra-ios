//
//  SignUpInteractorImpl.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation
import RxSwift
import GRPC
import NIOCore
import Logging

extension CallOptions {
    static func `default`(include timeout: Bool = true) -> CallOptions {
        var logger = Logger(label: "com.typi.ultra")
        logger.logLevel = .warning
        
        if let token = AppSettingsImpl.shared.appStore.token {
            return .init(customMetadata: .init(httpHeaders: ["Authorization": "Bearer \(token)"]),
                         timeLimit: timeout ? .timeout(.seconds(20)) : .none,
                         logger: logger)
        } else {
            PP.error("Called default() when token is nill")
            return .init(timeLimit: timeout ? .timeout(.seconds(20)) : .none, logger: logger)
        }
    }
}


