//
//  MediaRepository.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import UIKit
import RxSwift
import SDWebImage

enum ImageType {
    case preview, snapshot, origin
}

protocol MediaRepository {
    
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> { get set }
    func image(from message: Message, with type: ImageType) -> UIImage?
    func download(from message: Message) -> Single<Message>
    
    func upload(file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest>
}

class MediaRepositoryImpl {
    fileprivate let sdCache: SDImageCache
    fileprivate let appStore: AppSettingsStore
    fileprivate let messageDBService: MessageDBService
    fileprivate let fileService: FileServiceClientProtocol
    fileprivate let uploadFileInteractor: UseCase<[FileChunk], Void>
    fileprivate let createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>
    
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> = .init(value: [])
    
    init(sdCache: SDImageCache = .shared,
         uploadFileInteractor: UseCase<[FileChunk], Void>,
         appStore: AppSettingsStore = AppSettingsImpl.shared.appStore,
         fileService: FileServiceClientProtocol = AppSettingsImpl.shared.fileService,
         messageDBService: MessageDBService = AppSettingsImpl.shared.messageDBService,
         createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>) {
        self.sdCache = sdCache
        self.appStore = appStore
        self.fileService = fileService
        self.messageDBService = messageDBService
        self.uploadFileInteractor = uploadFileInteractor
        self.createFileSpaceInteractor = createFileSpaceInteractor
        
//        self.sdCache.clearDisk()
//        self.sdCache.clearMemory()
    }
}

extension MediaRepositoryImpl: MediaRepository {
   
    func upload(file:FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {
        let userID = appStore.userID()
        var message = Message.with { mess in
            mess.receiver = .with({ receiver in
                receiver.chatID = conversation.idintification
                receiver.userID = conversation.peer?.userID ?? ""
            })
            mess.meta = .with { $0.created = Date().nanosec }
            mess.sender = .with { $0.userID = userID }
            mess.id = UUID().uuidString
            mess.photo = .with({ photo in
                photo.fileName = ""
                photo.fileSize = Int64(file.data.count)
                photo.mimeType = file.mime
                photo.height = Int32(file.height)
                photo.width = Int32(file.width)
            })
        }

        return self.createFileSpaceInteractor
            .executeSingle(params: (file.data, message.photo.extensions))
            .map({ [weak self] chunks in
                guard let `self` = self else { throw NSError.selfIsNill }
                message.photo.fileID = chunks.first?.fileID ?? ""
                try self.storeImageInLocal(data: file.data, by: message)
                return chunks
            })
            .flatMap({ [weak self] response -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageDBService.save(message: message).map({ response })
            })
            .flatMap({ [weak self] response -> Single<Void> in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.uploadFileInteractor.executeSingle(params: response)
            })
            .map({ _ -> MessageSendRequest in
                return MessageSendRequest.with({ req in
                    req.peer.user = .with({ peer in
                        peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
                    })
                    req.message = message
                })
            })
    }
    
    
    func image(from message: Message, with type: ImageType) -> UIImage? {
        guard message.hasPhoto else { return nil }
        switch type {
        case .preview:
            return sdCache.imageFromCache(forKey: message.photo.previewFileId)
        case .snapshot:
            return sdCache.imageFromCache(forKey: message.photo.snapshotFileId)
        case .origin:
            return sdCache.imageFromCache(forKey: message.photo.originalFileId)
        }
    }
    
    func download(from message: Message) -> Single<Message> {
        var inProgressValues = try! downloadingImages.value()
        if inProgressValues.contains(where: {$0.fileID == message.photo.fileID }) {
            return Single.just(message)
        }

        let maxChunkSize = message.photo.fileSize / (512 * 1024)
        
        return Single<Message>.create {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            var params = FileDownloadRequest.with({
                $0.fileID = message.photo.fileID
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
                .flatMapThrowing({ [weak self] status in
                    guard let `self` = self else { throw NSError.selfIsNill }
                    return try self.storeImageInLocal(data: data, by: message)
                })
                .whenComplete { result in
                    switch result {
                    case .success:
                        params.fromChunkNumber = params.toChunkNumber
                        var images = try? self.downloadingImages.value()
                        images?.removeAll(where: {$0.fileID == params.fileID})
                        images?.append(params)
                        self.downloadingImages.on(.next(images ?? []))
                        observer(.success(message))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }

            return Disposables.create()
        }
    }
}

private extension MediaRepositoryImpl {
    func storeImageInLocal(data: Data, by message: Message) throws {
        guard let image = UIImage.sd_image(with: data)?.downsample(reductionAmount: 0.1),
              let low = image.compress(.low),
              let medium = image.compress(.medium) else {
            throw NSError.selfIsNill
        }
        self.sdCache.store(nil, imageData: low, forKey: message.photo.previewFileId, toDisk: true)
        sdCache.store(nil, imageData: medium, forKey: message.photo.snapshotFileId, toDisk: true)
        sdCache.store(nil, imageData: image.compress(.high), forKey: message.photo.originalFileId, toDisk: true)
    }
}

private extension PhotoMessage {
    var extensions:String { mimeType.components(separatedBy: "/").last ?? ""}
    var previewFileId: String { "preview_\(fileID)" }
    var originalFileId: String { "original_\(fileID)" }
    var snapshotFileId: String { "snapshot_\(fileID)" }
}

extension Message {
    var hasPhoto: Bool { self.photo.fileID != "" }
}

