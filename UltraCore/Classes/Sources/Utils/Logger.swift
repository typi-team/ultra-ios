//
//  Loger.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import CocoaLumberjack
import Foundation
import GRPC

enum LogLevel: Int {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
}

class PP {
    static var logLevel: LogLevel = .verbose
    
    static func initialize() {
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24hrs
        fileLogger.logFileManager.maximumNumberOfLogFiles = 5
        DDLog.add(DDOSLogger.sharedInstance)
        DDLog.add(fileLogger)
        dynamicLogLevel = .verbose
    }

    static func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        DDLogVerbose(message)
    }

    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        DDLogDebug(message)
    }

    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        DDLogInfo(message)
    }

    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        DDLogWarn(message)
    }

    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        DDLogError(message)
    }
    
    static func grpc(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        if let grpcError = error as? GRPCStatus {
            DDLogError("\(grpcError.message ?? "Not defined message") : \(grpcError.code)")
        } else {
            DDLogError(error.localizedDescription)
        }
    }

    private static func log(_ message: String, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(fileName):\(line) \(function) - \(message)"
        print(logMessage)
    }
}
