//
//  Error+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/24/23.
//

import GRPC

extension NSError {
    static var selfIsNill: NSError {
        NSError.init(domain: "Skip this error, because self is nil", code: 101)
    }
    
    static var objectsIsNill: NSError {
        let error = NSError.init(domain: "Skip this error, because object is nil", code: 101)
        PP.error(error.description)
        return error
    }
}

extension Error {
    var localeError: String {
        if let grpcError = self as? GRPCStatus {
            return "\(grpcError.message ?? "Not defined message") : \(grpcError.code)"
        } else {
            return self.localizedDescription
        }
    }
}
