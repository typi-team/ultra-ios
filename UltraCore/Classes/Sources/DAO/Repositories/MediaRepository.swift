//
//  MediaRepository.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import UIKit
import RxSwift
import AVFoundation

protocol MediaRepository {
    
    var uploadingMedias: BehaviorSubject<[FileDownloadRequest]> { get set }
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> { get set }
    
    func mediaURL(from message: Message) -> URL?
    func isUploading(from message: Message) -> Bool
    func download(from message: Message) -> Single<Message>
    func image(from message: Message) -> UIImage?
    func upload(file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest>
    func upload(message: Message, in conversation: Conversation) -> Single<MessageSendRequest>
}

class MediaRepositoryImpl {
    fileprivate let mediaUtils: MediaUtils
    fileprivate let appStore: AppSettingsStore
    fileprivate let messageDBService: MessageDBService
    fileprivate let fileService: FileServiceClientProtocol
    fileprivate let uploadFileInteractor: UseCase<[FileChunk], Void>
    fileprivate let createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>
    
    var currentVoice: BehaviorSubject<[VoiceMessage]> = .init(value: [])
    var uploadingMedias: BehaviorSubject<[FileDownloadRequest]> = .init(value: [])
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> = .init(value: [])
    
    init(mediaUtils: MediaUtils,
         uploadFileInteractor: UseCase<[FileChunk], Void>,
         appStore: AppSettingsStore = AppSettingsImpl.shared.appStore,
         fileService: FileServiceClientProtocol = AppSettingsImpl.shared.fileService,
         messageDBService: MessageDBService = AppSettingsImpl.shared.messageDBService,
         createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>) {
        
        self.appStore = appStore
        self.mediaUtils = mediaUtils
        self.fileService = fileService
        self.messageDBService = messageDBService
        self.uploadFileInteractor = uploadFileInteractor
        self.createFileSpaceInteractor = createFileSpaceInteractor
    }
}

extension MediaRepositoryImpl: MediaRepository {
    func mediaURL(from message: Message) -> URL? {
        return mediaUtils.mediaURL(from: message)
    }
    
    
    func isUploading(from message: Message) -> Bool {
        return try! self.uploadingMedias.value().contains(where: { $0.fileID == message.fileID })
    }

    func upload(file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {
        if file.mime.containsImage {
            return self.uploadImage(by: file, in: conversation, onPreUploadingFile: onPreUploadingFile)
        } else if file.mime.containsVideo {
            return self.uploadVideo(by: file, in: conversation, onPreUploadingFile: onPreUploadingFile)
        } else if file.mime.containsAudio{
            return self.uploadVoice(by: file, in: conversation, onPreUploadingFile: onPreUploadingFile)
        }else {
            return self.uploadFile(by: file, in: conversation, onPreUploadingFile: onPreUploadingFile)
        }
    }
    
    func upload(message: Message, in conversation: Conversation) -> Single<MessageSendRequest> {
        switch message.content {
        case .photo:
            return uploadFile(by: message, data: message.photo.placeholder, in: conversation)
        case .video:
            return uploadVideo(by: message, data: message.video.thumbPreview, url: URL(string: message.video.filePath), in: conversation)
        case .voice:
            return uploadFile(by: message, data: message.voice.data, in: conversation)
        default:
            return uploadFile(by: message, data: message.file.data, in: conversation)
        }
    }
    
    func image(from message: Message) -> UIImage? {
        return self.mediaUtils.image(from: message)
    }
    
    func download(from message: Message) -> Single<Message> {
        var inProgressValues = try! downloadingImages.value()
        guard let fileID = message.fileID,
              !inProgressValues.contains(where: {$0.fileID == fileID}) else {
            return Single.just(message)
        }

        let maxChunkSize = message.fileSize / (512 * 1024)
        
        return Single<Message>.create {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            var params = FileDownloadRequest.with({
                $0.fileID = fileID
                $0.fromChunkNumber = 0
                $0.toChunkNumber = maxChunkSize
            })

            var data: Data = .init()

            inProgressValues.append(params)
            self.downloadingImages.on(.next(inProgressValues))

            self.fileService
                .download(params, callOptions: .default(), handler: { chunk in
                    data.append(chunk.data)
                    params.fromChunkNumber = chunk.seqNum
                    PP.info((Float(params.fromChunkNumber) / Float(params.toChunkNumber)).description)
                    var images = try? self.downloadingImages.value()
                    images?.removeAll(where: {$0.fileID == chunk.fileID})
                    images?.append(params)
                    self.downloadingImages.on(.next(images ?? []))
                })
                .status
                .whenComplete {[weak self] result in
                    guard let `self` = self else { return observer(.failure(NSError.selfIsNill))}
                    switch result {
                    case .success:
                        do {
                            if message.hasVoice {
                                try self.mediaUtils.write(data, file: message.voice.originalVoiceFileId, and: message.voice.extensions)
                                params.fromChunkNumber = params.toChunkNumber
                                var images = try? self.downloadingImages.value()
                                images?.removeAll(where: { $0.fileID == params.fileID })
                                images?.append(params)
                                self.downloadingImages.on(.next(images ?? []))
                                observer(.success(message))
                            } else if message.hasPhoto {
                                try self.mediaUtils.write(data, file: message.photo.originalFileId, and: message.photo.extensions)
                                try self.mediaUtils.write(data, file: message.photo.previewFileId, and: message.photo.extensions)
                                
                                params.fromChunkNumber = params.toChunkNumber
                                var images = try? self.downloadingImages.value()
                                images?.removeAll(where: { $0.fileID == params.fileID })
                                images?.append(params)
                                self.downloadingImages.on(.next(images ?? []))
                                observer(.success(message))
                            } else if message.hasVideo {
                                Single<URL>
                                    .just(try self.mediaUtils.write(data, file: message.video.originalVideoFileId, and: message.video.extensions))
                                    .flatMap({ (url: URL) -> Single<Data> in self.mediaUtils.thumbnailData(in: url) })
                                    .map({ imageData in try self.mediaUtils.write(imageData, file: message.video.previewVideoFileId, and: "png")})
                                    .subscribe(onSuccess: {
                                        params.fromChunkNumber = params.toChunkNumber
                                        var images = try? self.downloadingImages.value()
                                        images?.removeAll(where: { $0.fileID == params.fileID })
                                        images?.append(params)
                                        self.downloadingImages.on(.next(images ?? []))
                                        observer(.success(message))
                                    })
                                    .dispose()
                                return
                            } else if message.hasFile {
                                try self.mediaUtils.write(data, file: message.file.originalFileId, and: message.file.extensions)
                                
                                params.fromChunkNumber = params.toChunkNumber
                                var images = try? self.downloadingImages.value()
                                images?.removeAll(where: { $0.fileID == params.fileID })
                                images?.append(params)
                                self.downloadingImages.on(.next(images ?? []))
                                observer(.success(message))
                            }
                        } catch {
                            observer(.failure(error))
                        }
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }

            return Disposables.create()
        }
    }
}

private extension MediaRepositoryImpl {
    
    func uploadFile(by message: Message, data: Data, in conversation: Conversation) -> Single<MessageSendRequest> {
        var message = message
        return self.createFileSpaceInteractor.executeSingle(params: (data, getFileMessageMimeType(message: message)))
            .do(onSuccess: { [weak self] chunks in
                guard let `self` = self else { return }
                var images = try self.uploadingMedias.value()
                images.append(FileDownloadRequest.with({
                    $0.fileID = chunks.first?.fileID ?? ""
                    $0.fromChunkNumber = 0
                    $0.toChunkNumber = Int64(chunks.count)
                }))
                self.uploadingMedias.on(.next(images))
            })
            .do(onSuccess: { [weak self] chunks in
                guard let `self` = self else { throw NSError.selfIsNill }
                let originalFileId: String
                let extensions: String
                switch message.content {
                case .photo:
                    message.photo.fileID = chunks.first?.fileID ?? ""
                    originalFileId = message.photo.originalFileId
                    extensions = message.photo.extensions
                case .voice:
                    message.voice.fileID = chunks.first?.fileID ?? ""
                    originalFileId = message.voice.originalVoiceFileId
                    extensions = message.voice.extensions
                case .file:
                    message.file.fileID = chunks.first?.fileID ?? ""
                    originalFileId = message.file.originalFileId
                    extensions = message.file.extensions
                default:
                    originalFileId = ""
                    extensions = ""
                }
                try self.mediaUtils.write(data, file: originalFileId, and: extensions)
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 80) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageDBService.save(message: message).map({ response })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 60) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<Void> in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.uploadFileInteractor.executeSingle(params: response)
            })
                
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 80) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .map({ _ -> MessageSendRequest in
                MessageSendRequest.with({ req in
                    req.peer.user = .with({ peer in
                        peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
                    })
                    req.message = message
                })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.photo.fileID })
                self.uploadingMedias.on(.next(process))
            }, onError: {[weak self] (error: Error) in
                PP.warning(error.localizedDescription)
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.photo.fileID })
                self.uploadingMedias.on(.next(process))
            })
    }
    
    private func getFileMessageMimeType(message: Message) -> String {
        let mimeType: String
        switch message.content {
        case let .photo(photoMessage):
            mimeType = photoMessage.mimeType
        case let .voice(voiceMessage):
            mimeType = voiceMessage.mimeType
        case let .file(fileMessage):
            mimeType = fileMessage.mimeType
        default:
            mimeType = ""
        }
        return mimeType
    }
    
    func uploadImage(by file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {
        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.photo = .with({ photo in
            photo.fileName = ""
            photo.fileSize = Int64(file.data.count)
            photo.mimeType = file.mime
            photo.height = Int32(file.height)
            photo.width = Int32(file.width)
            photo.placeholder = file.data
            photo.fileID = UUID().uuidString
        })
        preUploading(message: message, conversation: conversation, onCompletion: onPreUploadingFile)
        return upload(message: message, in: conversation)
    }
    
    func uploadFile(by file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {

        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.file = .with({ photo in
            photo.mimeType = file.mime
            photo.fileSize = Int64(file.data.count)
            photo.fileName = file.url?.pathComponents.last ?? " "
            photo.data = file.data
        })

        preUploading(message: message, conversation: conversation, onCompletion: onPreUploadingFile)
        return upload(message: message, in: conversation)
    }
    
    func uploadVideo(by file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {

        guard let url = file.url else { return Single.error(NSError.objectsIsNill )}
        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        
        message.video = .with({ photo in
            photo.fileName = ""
            photo.fileSize = Int64(file.data.count)
            photo.mimeType = file.mime
            photo.height = Int32(file.height)
            photo.width = Int32(file.width)
            photo.fileID = UUID().uuidString
            if let data = getThumbnailImageData(forUrl: url) {
                photo.thumbPreview = data
            }
            photo.filePath = url.absoluteString
        })

        preUploading(message: message, conversation: conversation, onCompletion: onPreUploadingFile)
        return uploadVideo(by: message, data: file.data, url: url, in: conversation)
    }
    
    func uploadVideo(by message: Message, data: Data, url: URL?, in conversation: Conversation) -> Single<MessageSendRequest> {
        guard let url else { return Single.error(NSError.objectsIsNill )}
        var message = message
        var thumbnailData: Data = .init()
        return self.mediaUtils.thumbnailData(in: url)
                .do(onSuccess: {thumbnailData = $0 })
                    .flatMap({data -> Single<[FileChunk]> in
                        return self.createFileSpaceInteractor.executeSingle(params: (data: data, extens: "image/png"))})
                    .do(onSuccess: { chunks in
                        message.video.thumbFileID = chunks.first?.fileID ?? ""
                    })
                    .flatMap({ chunks in
                        return self.uploadFileInteractor.executeSingle(params: chunks)
                    })
                        
            .flatMap {[weak self] _ -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.createFileSpaceInteractor
                    .executeSingle(params: (data, message.video.mimeType))
            }
            .do(onSuccess: {[weak self] chunks in
                message.video.fileID = chunks.first?.fileID ?? ""
                try self?.mediaUtils.write(thumbnailData, file: message.video.previewVideoFileId, and: "png")
            })
            .do(onSuccess: { [weak self] chunks in
                guard let `self` = self else { return }
                var images = try self.uploadingMedias.value()
                images.append(FileDownloadRequest.with({
                    $0.fileID = chunks.first?.fileID ?? ""
                    $0.fromChunkNumber = 0
                    $0.toChunkNumber = Int64(chunks.count)
                }))
                self.uploadingMedias.on(.next(images))
            })
            .do( onSuccess: { [weak self] chunks in
                guard let `self` = self else { throw NSError.selfIsNill }
                message.video.fileID = chunks.first?.fileID ?? ""
                try self.mediaUtils.write(data, file: message.video.originalVideoFileId, and: message.video.extensions)
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.toChunkNumber = file.toChunkNumber / 10
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageDBService.save(message: message).map({ response })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.toChunkNumber = file.toChunkNumber / 40
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<Void> in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.uploadFileInteractor.executeSingle(params: response)
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.toChunkNumber = file.toChunkNumber
                self.uploadingMedias.on(.next(process))
            })
            .map({ _ -> MessageSendRequest in
                return MessageSendRequest.with({ req in
                    req.peer.user = .with({ peer in
                        peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
                    })
                    req.message = message
                })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.fileID })
                self.uploadingMedias.on(.next(process))
            })
    }
    
    
    func uploadVoice(by file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {

        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        
        message.voice = .with({ photo in
            photo.mimeType = file.mime
            photo.duration = file.duration.nanosec
            photo.fileSize = Int64(file.data.count)
            photo.fileName = file.url?.lastPathComponent ?? ""
            photo.data = file.data
        })
        preUploading(message: message, conversation: conversation, onCompletion: onPreUploadingFile)
        return upload(message: message, in: conversation)
    }
    
    private func preUploading(message: Message, conversation: Conversation, onCompletion: (MessageSendRequest) -> Void) {
        let request = MessageSendRequest.with({ req in
            req.peer.user = .with({ peer in
                peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
            })
            req.message = message
        })
        onCompletion(request)
    }
    
    private func getThumbnailImageData(forUrl url: URL) -> Data? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage, scale: 1, orientation: .right).pngData()
        } catch let error {
            print(error)
        }
        return nil
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
