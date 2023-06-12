//
//  MediaRepository.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import UIKit
import RxSwift

enum ImageType {
    case preview, snapshot, origin
}

protocol MediaRepository {
    
    var uploadingMedias: BehaviorSubject<[FileDownloadRequest]> { get set }
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> { get set }
    
    func isUploading(from message: Message) -> Bool
    func download(from message: Message) -> Single<Message>
    func image(from message: Message, with type: ImageType) -> UIImage?
    func upload(file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest>
}

class MediaRepositoryImpl {
    fileprivate let mediaUtils: MediaUtils
    fileprivate let appStore: AppSettingsStore
    fileprivate let messageDBService: MessageDBService
    fileprivate let fileService: FileServiceClientProtocol
    fileprivate let uploadFileInteractor: UseCase<[FileChunk], Void>
    fileprivate let createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>
    
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
        
//        self.sdCache.clearDisk()
//        self.sdCache.clearMemory()
    }
}

extension MediaRepositoryImpl: MediaRepository {
    
    func isUploading(from message: Message) -> Bool {
        return try! self.uploadingMedias.value().contains(where: { $0.fileID == message.fileID })
    }

    func upload(file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {
        if file.mime.containsImage {
            return self.uploadImage(by: file, in: conversation)
        } else if file.mime.containsVideo {
            return self.uploadVideo(by: file, in: conversation)
        }else {
            fatalError()
        }
    }
    
    
    func image(from message: Message, with type: ImageType) -> UIImage? {
        return self.mediaUtils.image(from: message, with: type)
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
                            if message.hasPhoto {
                                try self.mediaUtils.storeImageInLocal(data: data, by: message)
                                params.fromChunkNumber = params.toChunkNumber
                                var images = try? self.downloadingImages.value()
                                images?.removeAll(where: { $0.fileID == params.fileID })
                                images?.append(params)
                                self.downloadingImages.on(.next(images ?? []))
                                observer(.success(message))
                            } else {
                                Single<URL>.just(try self.mediaUtils.save(data, video: message.video))
                                    .flatMap({ (url: URL) -> Single<Data> in self.mediaUtils.thumbnailData(in: url) })
                                    .map({ imageData in try self.mediaUtils.storeVideoImageInLocal(data: imageData, by: message.video) })
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
    
    func uploadImage(by file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {

        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.photo = .with({ photo in
            photo.fileName = ""
            photo.fileSize = Int64(file.data.count)
            photo.mimeType = file.mime
            photo.height = Int32(file.height)
            photo.width = Int32(file.width)
        })

        return self.createFileSpaceInteractor.executeSingle(params: (file.data, message.photo.mimeType))
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
            .map({ [weak self] chunks in
                guard let `self` = self else { throw NSError.selfIsNill }
                message.photo.fileID = chunks.first?.fileID ?? ""
                try self.mediaUtils.storeImageInLocal(data: file.data, by: message)
                return chunks
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber * 9
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
                file.fromChunkNumber = file.toChunkNumber * 60
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
                file.fromChunkNumber = file.toChunkNumber
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
            })
    }
    
    func uploadVideo(by file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {

        guard let url = file.url else { return Single.error(NSError.objectsIsNill )}
        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        
        message.video = .with({ photo in
            photo.fileName = ""
            photo.fileSize = Int64(file.data.count)
            photo.mimeType = file.mime
            photo.height = Int32(file.height)
            photo.width = Int32(file.width)
        })
        
        
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
                    .executeSingle(params: (file.data, message.video.mimeType))
            }
            .do(onSuccess: {[weak self] chunks in
                message.video.fileID = chunks.first?.fileID ?? ""
                try? self?.mediaUtils.storeVideoImageInLocal(data: thumbnailData, by: message.video)
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
                try self.mediaUtils.save(file.data, video: message.video)
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
}

