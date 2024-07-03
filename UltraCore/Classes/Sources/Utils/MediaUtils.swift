//
//  MediaUtils.swift
//  UltraCore
//
//  Created by Slam on 6/10/23.
//


import UIKit
import RxSwift
import AVFoundation
import MobileCoreServices

class MediaUtils {
    static func image(from contact: ContactDisplayable) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let path = contact.imagePath else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(path)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }

    func previewImage(from message: Message) -> UIImage? {
        guard let data = try? readFileWithName(fileName: message.hasPhoto ? message.photo.previewFileIdWithExtensions : message.video.previewVideoFileIdWithExtension) else { return nil }
        return UIImage(data: data)
    }

    func image(from message: Message) -> UIImage? {
        guard let data = try? readFileWithName(fileName: message.hasPhoto ? message.photo.originalFileIdWithExtension : message.video.previewVideoFileIdWithExtension) else { return nil }
        return UIImage(data: data)
    }
    
    func videoPreview(from message: Message) -> UIImage? {
        let url = createDocumentsDirectory(file: message.video.originalVideoFileId, and: message.video.extensions)
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero,
                                                         actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
    
    func createMessageForUpload(in conversation: Conversation, with userID: String) -> Message {
        return Message.with { mess in
            mess.receiver = .with({ receiver in
                receiver.chatID = conversation.idintification
                receiver.userID = conversation.peers.first?.userID ?? ""
            })
            mess.meta = .with { $0.created = Date().nanosec }
            mess.sender = .with { $0.userID = userID }
            mess.id = UUID().uuidString
            if let messageMeta = UltraCoreSettings.delegate?.getMessageMeta() {
                mess.properties = messageMeta
            }
        }
    }
    
    @discardableResult
    func write(_ data: Data, file path: String, and extension: String) throws -> URL {
        let fileURL = createDocumentsDirectory(file: path, and: `extension`)
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    @discardableResult
    func compressedWrite(_ data: Data, file path: String, and extension: String) throws -> URL {
        let fileURL = createDocumentsDirectory(file: path, and: `extension`)
        guard let compressedData = compressImageData(from: data) else {
            throw NSError(domain: "Couldn't compress image", code: 100)
        }
        try compressedData.write(to: fileURL, options: .atomic)
        return fileURL
    }

    func delete(url: URL) {
        if FileManager.default.fileExists(atPath: url.absoluteString) {
            do {
                try FileManager.default.removeItem(atPath: url.absoluteString)
            } catch {
                print("Could not delete file, probably read-only filesystem")
            }
        }
    }
    
    private func createDocumentsDirectory(file path: String, and extension: String) -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(path).appendingPathExtension(`extension`)
        return fileURL
    }
    
    func readFileWithName(fileName: String) throws -> Data? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: fileURL)
        return data
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
                
                let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero,
                                                             actualTime: nil)
                observer(.success(UIImage.init(cgImage: cgImage)))
            }catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func mediaURL(from message: Message) -> URL? {
        guard let originalFileIdWithExtension = message.originalFileIdWithExtension else { return nil }
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(originalFileIdWithExtension)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            PP.warning("Файл с именем \(originalFileIdWithExtension) не найден.")
            return nil
        }
    }
    
    func createAudioGraphImage(from path: String, image: UIImage, completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let data = image.pngData() else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            do {
                try self?.write(data, file: path, and: "png")
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    func compressImageData(from data: Data) -> Data? {
        guard let img = UIImage(data: data) else {
            return nil
        }
        var actualHeight: CGFloat = img.size.height
        var actualWidth: CGFloat = img.size.width
        let maxHeight: CGFloat = 200.0 * UIScreen.main.scale
        let maxWidth: CGFloat = 300.0 * UIScreen.main.scale
        var imgRatio: CGFloat = actualWidth / actualHeight
        let maxRatio: CGFloat = maxWidth / maxHeight
        var compressionQuality: CGFloat = 1.0

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        img.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        guard let imageData = img.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        return imageData
    }
}


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
    
    var containsVoice: Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
}

extension Message {
    var originalFileIdWithExtension: String? {
        if hasPhoto {
            return photo.originalFileIdWithExtension
        } else if hasVideo {
            return video.originalVideoFileIdWithExtension
        } else if hasFile {
            return file.originalFileIdWithExtension
        } else if hasVoice {
            return voice.originalFileIdWithExtension
        } else {
            return nil
        }
    }
}

extension VideoMessage {
    var extensions:String { mimeType.components(separatedBy: "/").last ?? ""}
    
    var previewVideoFileId: String { "preview_video_\(fileID)" }
    var originalVideoFileId: String { "original_video_\(fileID)" }
    
    var previewVideoFileIdWithExtension: String { "preview_video_\(fileID).png" }
    var originalVideoFileIdWithExtension: String { "original_video_\(fileID).\(extensions)" }
}

extension VoiceMessage {
    var extensions:String { "wav" }
    var originalVoiceFileId: String { "original_voice\(fileID)" }
    var originalFileIdWithExtension: String { "\(originalVoiceFileId).\(extensions)" }
}

extension PhotoMessage {

    var extensions:String { mimeType.components(separatedBy: "/").last ?? ""}

    var previewFileId: String { "preview_\(fileID)" }
    var previewFileIdWithExtensions: String { "preview_\(fileID).\(extensions)" }

    var originalFileId: String { "original_\(fileID)" }
    var originalFileIdWithExtension: String { "original_\(fileID).\(extensions)" }
}

extension FileMessage {
    var originalFileId: String { "original_\(fileID)" }
    var extensions: String {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue(),
              let type = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension)?.takeRetainedValue() as? String else {
            return mimeType.components(separatedBy: "/").last ?? ""
        }

        return type
    }
    
    var originalFileIdWithExtension: String { "original_\(fileID).\(extensions)" }
}

extension Message {
    var hasFile: Bool { self.file.fileID != "" }
    var hasPhoto: Bool { self.photo.fileID != "" }
    var hasVideo: Bool { self.video.fileID != "" }
    var hasVoice: Bool { self.voice.fileID != "" }
    var hasAudio: Bool { self.audio.fileID != "" }

    var fileID: String? {
        if hasPhoto {
            return photo.fileID
        } else if hasVideo {
            return video.fileID
        } else if hasFile {
            return file.fileID
        } else if hasVoice {
            return voice.fileID
        } else if hasAudio {
            return audio.fileID
        } else {
            return nil
        }
    }
    
    var fileSize: Int64 {
        if hasPhoto {
            return photo.fileSize
        } else if hasVideo {
            return video.fileSize
        } else if hasFile {
            return file.fileSize
        } else if hasAudio {
            return audio.fileSize
        } else if hasVoice {
            return voice.fileSize
        } else {
            return 0
        }
    }
    
    var hasAttachment: Bool {
        hasFile || hasPhoto || hasVideo || hasVoice || hasAudio
    }
}

