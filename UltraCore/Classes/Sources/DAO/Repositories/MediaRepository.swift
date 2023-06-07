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
}

class MediaRepositoryImpl {
    
    fileprivate let fileService: FileServiceClientProtocol
    
    fileprivate let sdCache: SDImageCache
    
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> = .init(value: [])
    
    init(sdCache: SDImageCache = .shared,
         fileService: FileServiceClientProtocol = AppSettingsImpl.shared.fileService) {
        self.sdCache = sdCache
        self.fileService = fileService
        self.sdCache.clearDisk()
        self.sdCache.clearMemory()
    }
}

extension MediaRepositoryImpl: MediaRepository {
    
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
                    self.downloadingImages.on(.next(try! self.downloadingImages.value()))
                })
                .status
                .flatMapThrowing({ [weak self] status in
                    guard let `self` = self else { throw NSError.selfIsNill }
                    return try self.storeImageInLocal(data: data, by: message)
                })
                .whenComplete { result in
                    switch result {
                    case .success:
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
              let low = image.jpeg(.low),
              let medium = image.jpeg(.medium) else {
            throw NSError.selfIsNill
        }
        self.sdCache.store(nil, imageData: low, forKey: message.photo.previewFileId, toDisk: true)
        sdCache.store(nil, imageData: medium, forKey: message.photo.snapshotFileId, toDisk: true)
        sdCache.store(nil, imageData: image.jpeg(.high), forKey: message.photo.originalFileId, toDisk: true)
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

