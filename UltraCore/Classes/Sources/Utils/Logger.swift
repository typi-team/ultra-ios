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

public class PP {
    static var logLevel: LogLevel = .verbose
    
    static func initialize() {
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24hrs
        fileLogger.logFileManager.maximumNumberOfLogFiles = 5
        DDLog.add(DDOSLogger.sharedInstance)
        DDLog.add(fileLogger)
        dynamicLogLevel = .error
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
    
    public static func getLogFile(completion: @escaping ((URL) -> Void)) {
        guard let fileLogger = DDLog.allLoggers.compactMap({ $0 as? DDFileLogger }).first else {
            return
        }
        let logFileURLs = fileLogger.logFileManager.sortedLogFilePaths.map(URL.init(fileURLWithPath:))
        let temporaryDirectory = FileManager.default.temporaryDirectory
        // Create a temporary directory
        let logsDir = temporaryDirectory.appendingPathComponent("LogFiles")
        if !FileManager.default.fileExists(atPath: logsDir.path) {
            try? FileManager.default.createDirectory(atPath: logsDir.path, withIntermediateDirectories: true)
        }
        
        // Copy items to one folder
        logFileURLs.forEach { item in
            let pathExtension = item.lastPathComponent
            let itemURL = logsDir.appendingPathComponent(pathExtension)
            if FileManager.default.fileExists(atPath: itemURL.path) {
                try? FileManager.default.removeItem(at: itemURL)
            }
            try? FileManager.default.copyItem(at: item, to: itemURL)
        }
        
        let fileCoordinator = NSFileCoordinator()
        var error: NSError?
        
        // Archive files into zip
        fileCoordinator.coordinate(readingItemAt: logsDir, options: [.forUploading], error: &error) { archiveURL in
            let archivePath = temporaryDirectory.appendingPathComponent("logs.zip")
            
            if FileManager.default.fileExists(atPath: archivePath.path) {
                try? FileManager.default.removeItem(at: archivePath)
            }
            try? FileManager.default.moveItem(at: archiveURL, to: archivePath)
            completion(archivePath)
        }

    }

    private static func log(_ message: String, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(fileName):\(line) \(function) - \(message)"
        print(logMessage)
    }
}
