//
//  MediaRepository.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import UIKit
import RxSwift

protocol MediaRepository {
    
    var uploadingMedias: BehaviorSubject<[FileDownloadRequest]> { get set }
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> { get set }
    
    func mediaURL(from message: Message) -> URL?
    func isUploading(from message: Message) -> Bool
    func download(from message: Message) -> Single<Message>
    func image(from message: Message) -> UIImage?
    func videoPreview(from message: Message) -> UIImage?
    func upload(file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest>
    func upload(message: Message) -> Single<MessageSendRequest>
}

class MediaRepositoryImpl {
    fileprivate let mediaUtils: MediaUtils
    fileprivate let appStore: AppSettingsStore
    fileprivate let messageDBService: MessageDBService
    fileprivate let fileService: FileServiceClientProtocol
    fileprivate let uploadFileInteractor: GRPCErrorUseCase<[FileChunk], Void>
    fileprivate let createFileSpaceInteractor: GRPCErrorUseCase<(data: Data, extens: String), [FileChunk]>
    
    var currentVoice: BehaviorSubject<[VoiceMessage]> = .init(value: [])
    var uploadingMedias: BehaviorSubject<[FileDownloadRequest]> = .init(value: [])
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> = .init(value: [])
    
    init(mediaUtils: MediaUtils,
         uploadFileInteractor: GRPCErrorUseCase<[FileChunk], Void>,
         appStore: AppSettingsStore = AppSettingsImpl.shared.appStore,
         fileService: FileServiceClientProtocol = AppSettingsImpl.shared.fileService,
         messageDBService: MessageDBService = AppSettingsImpl.shared.messageDBService,
         createFileSpaceInteractor: GRPCErrorUseCase<(data: Data, extens: String), [FileChunk]>) {
        
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
    
    func image(from message: Message) -> UIImage? {
        return self.mediaUtils.image(from: message)
    }
    
    func videoPreview(from message: Message) -> UIImage? {
        return mediaUtils.videoPreview(from: message)
    }
    
    func download(from message: Message) -> Single<Message> {
        var inProgressValues = try! downloadingImages.value()
        guard let fileID = message.fileID,
              !inProgressValues.contains(where: {$0.fileID == fileID}) else {
            return Single.just(message)
        }

        // Need to have at least 1 as a max chunk size for voice file to have progress.
        let maxChunkSize = max((message.fileSize / (512 * 1024)), 1)

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
                .download(params, callOptions: .default(include: false), handler: { chunk in
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
    
    func uploadImage(by file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {
        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.photo = .with({ photo in
            photo.fileName = ""
            photo.fileSize = Int64(file.data.count)
            photo.mimeType = file.mime
            photo.height = Int32(file.height)
            photo.width = Int32(file.width)
            photo.fileID = UUID().uuidString
        })
        preUploading(message: message, file: file, conversation: conversation, onCompletion: onPreUploadingFile)
        return upload(message: message)
    }
    
    func uploadFile(by file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {
        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.file = .with({ photo in
            photo.mimeType = file.mime
            photo.fileSize = Int64(file.data.count)
            photo.fileName = file.url?.pathComponents.last ?? " "
            photo.fileID = UUID().uuidString
        })
        preUploading(message: message, file: file, conversation: conversation, onCompletion: onPreUploadingFile)
        return upload(message: message)
    }
    
    func uploadVideo(by file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {
        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.video = .with({ photo in
            photo.fileName = ""
            photo.fileSize = Int64(file.data.count)
            photo.mimeType = file.mime
            photo.height = Int32(file.height)
            photo.width = Int32(file.width)
            photo.fileID = UUID().uuidString
        })
        preUploading(message: message, file: file, conversation: conversation, onCompletion: onPreUploadingFile)
        return uploadVideo(message: message)
    }
    
    func uploadVoice(by file: FileUpload, in conversation: Conversation, onPreUploadingFile: (MessageSendRequest) -> Void) -> Single<MessageSendRequest> {
        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.voice = .with({ photo in
            photo.mimeType = file.mime
            photo.duration = file.duration.nanosec
            photo.fileSize = Int64(file.data.count)
            photo.fileName = file.url?.lastPathComponent ?? ""
            photo.fileID = UUID().uuidString
        })
        preUploading(message: message, file: file, conversation: conversation, onCompletion: onPreUploadingFile)
        return upload(message: message)
    }
    
    private func preUploading(
        message: Message,
        file: FileUpload,
        conversation: Conversation,
        onCompletion: (MessageSendRequest) -> Void)
    {
        do {
            let originalFileId: String
            let extensions: String
            switch message.content {
            case .photo:
                originalFileId = message.photo.originalFileId
                extensions = message.photo.extensions
            case .voice:
                originalFileId = message.voice.originalVoiceFileId
                extensions = message.voice.extensions
            case .file:
                originalFileId = message.file.originalFileId
                extensions = message.file.extensions
            case .video:
                originalFileId = message.video.originalVideoFileId
                extensions = message.video.extensions
            default:
                originalFileId = ""
                extensions = ""
            }
            try mediaUtils.write(file.data, file: originalFileId, and: extensions)
            let request = MessageSendRequest.with({ req in
                req.peer.user = .with({ peer in
                    peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
                })
                req.message = message
            })
            onCompletion(request)
        } catch {}
    }
}

extension MediaRepositoryImpl {
    
    func upload(message: Message) -> Single<MessageSendRequest> {
        switch message.content {
        case .video:
            return uploadVideo(message: message)
        default:
            return uploadMedia(message: message)
        }
    }
    
    private func uploadMedia(message: Message) -> Single<MessageSendRequest> {
        guard let url = mediaUtils.mediaURL(from: message),
                let data = getDataFromURL(url: url) else {
            return Single.error(NSError.objectsIsNill)
        }
        
        var message = message
        return self.createFileSpaceInteractor.executeSingle(params: (data, mimeType(message: message)))
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
                self.mediaUtils.delete(url: url)
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
                        peer.userID = message.receiver.userID
                    })
                    req.message = message
                })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.fileID })
                self.uploadingMedias.on(.next(process))
            }, onError: {[weak self] (error: Error) in
                PP.warning(error.localizedDescription)
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.fileID })
                self.uploadingMedias.on(.next(process))
            })
    }
    
    private func uploadVideo(message: Message) -> Single<MessageSendRequest>  {
        guard let url = mediaUtils.mediaURL(from: message),
                let data = getDataFromURL(url: url) else {
            return Single.error(NSError.objectsIsNill)
        }
        var messageToDelete = message
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
                self.mediaUtils.delete(url: url)
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
                let _ = self.messageDBService.delete(messages: [messageToDelete], in: nil)
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
                        peer.userID = message.receiver.userID
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
    
    private func getDataFromURL(url: URL) -> Data? {
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            return nil
        }
    }
    
    private func mimeType(message: Message) -> String {
        switch message.content {
        case .photo:
            return message.photo.mimeType
        case .voice:
            return message.voice.mimeType
        case .file:
            return message.file.mimeType
        default:
            return message.photo.mimeType
        }
    }
    
}
