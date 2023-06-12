//
//  MediaUtils.swift
//  UltraCore
//
//  Created by Slam on 6/10/23.
//


import UIKit
import RxSwift
import SDWebImage
import AVFoundation
import MobileCoreServices

class MediaUtils {
    
    fileprivate let sdCache: SDImageCache
    
    init(sdCache: SDImageCache = .shared) {
        self.sdCache = sdCache
    }
    
    func image(from message: Message, with type: ImageType) -> UIImage? {
        if message.hasPhoto {
            switch type {
            case .preview:
                return sdCache.imageFromCache(forKey: message.photo.previewFileId)
            case .snapshot:
                return sdCache.imageFromCache(forKey: message.photo.snapshotFileId)
            case .origin:
                return sdCache.imageFromCache(forKey: message.photo.originalFileId)
            }
        } else if message.hasVideo {
            switch type {
            case .preview:
                return sdCache.imageFromCache(forKey: message.video.previewVideoFileId)
            case .snapshot:
                return sdCache.imageFromCache(forKey: message.video.originalVideoFileId)
            case .origin:
                return sdCache.imageFromCache(forKey: message.video.originalVideoFileId)
            }
        } else {
            return nil
        }
    }
    
    func createMessageForUpload(in conversation: Conversation, with userID: String) -> Message {
        return Message.with { mess in
            mess.receiver = .with({ receiver in
                receiver.chatID = conversation.idintification
                receiver.userID = conversation.peer?.userID ?? ""
            })
            mess.meta = .with { $0.created = Date().nanosec }
            mess.sender = .with { $0.userID = userID }
            mess.id = UUID().uuidString
        }
    }
    
    func storeImageInLocal(data: Data, by message: Message) throws {
        guard let image = UIImage.sd_image(with: data)?.downsample(reductionAmount: 0.1),
              let low = image.compress(.low),
              let medium = image.compress(.medium) else {
            throw NSError.objectsIsNill
        }
        self.sdCache.store(nil, imageData: low, forKey: message.photo.previewFileId, toDisk: true)
        sdCache.store(nil, imageData: medium, forKey: message.photo.snapshotFileId, toDisk: true)
        sdCache.store(nil, imageData: image.compress(.high), forKey: message.photo.originalFileId, toDisk: true)
    }
    
    func storeVideoImageInLocal(data: Data, by message: VideoMessage) throws {
        guard let image = UIImage.sd_image(with: data)?.downsample(reductionAmount: 1.0),
              let low = image.compress(.low),
              let medium = image.compress(.medium) else {
            throw NSError.objectsIsNill
        }
        self.sdCache.store(nil, imageData: low, forKey: message.previewVideoFileId, toDisk: true)
        self.sdCache.store(nil, imageData: medium, forKey: message.originalVideoFileId, toDisk: true)
    }
    
    @discardableResult
    func save(_ data: Data, video message: VideoMessage) throws -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(message.fileID).\(message.extensions)")
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    func videoURL(file id: String) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(id)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            PP.warning("Файл с именем \(id) не найден.")
            return nil
        }
    }
    
    func thumbnailData(in url: URL) -> Single<Data> {
        return self.thumbnail(in: url)
            .map({ $0.downsample(reductionAmount: 0.4)?
                .compress(.medium) ?? Data() })
    }
    
    func thumbnail(in url: URL) -> Single<UIImage> {
        return Single.create { observer -> Disposable in
            do {
                let asset = AVURLAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                let cgImage = try imageGenerator.copyCGImage(at: kCMTimeZero,
                                                             actualTime: nil)
                observer(.success(UIImage.init(cgImage: cgImage)))
            }catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
}

typealias MimeType = String

extension URL {
    func mimeType() -> MimeType {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as MimeType
            }
        }
        return "application/octet-stream" as MimeType
    }
}

extension MimeType {
    var containsImage: Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }

    var containsAudio: Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }

    var containsVideo: Bool {
        
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }
}

extension VideoMessage {
    var extensions:String { mimeType.components(separatedBy: "/").last ?? ""}
    var previewVideoFileId: String { "preview_video_\(fileID)" }
    var originalVideoFileId: String { "original_video_\(fileID)" }
}

extension PhotoMessage {
    var extensions:String { mimeType.components(separatedBy: "/").last ?? ""}
    var previewFileId: String { "preview_\(fileID)" }
    var originalFileId: String { "original_\(fileID)" }
    var snapshotFileId: String { "snapshot_\(fileID)" }
}

extension Message {
    var hasPhoto: Bool { self.photo.fileID != "" }
    var hasVideo: Bool { self.video.fileID != "" }
    var fileID: String? {
        if hasPhoto {
            return photo.fileID
        } else if hasVideo {
            return video.fileID
        } else {
            return nil
        }
    }
    
    var fileSize: Int64 {
        if hasPhoto {
            return photo.fileSize
        } else if hasVideo {
            return video.fileSize
        } else {
            return 0
        }
    }
}

