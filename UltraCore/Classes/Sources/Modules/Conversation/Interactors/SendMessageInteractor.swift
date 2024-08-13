//
//  SendMessageInteractor.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import Foundation
import RxSwift

class SendMessageInteractor: GRPCErrorUseCase<MessageSendRequest, MessageSendResponse> {
    static var messageQueue = DispatchQueue(label: "com.ultra.sendMessageQueue")

    override func job(params: MessageSendRequest) -> Single<MessageSendResponse> {
        PP.debug("[Message] [Send]: Sending message with params \(params)")
        return Single.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }

            Self.messageQueue.sync {
                AppSettingsImpl.shared.messageService.send(params, callOptions: .default()).response.whenComplete { result in
                    switch result {
                    case let .success(response):
                        observer(.success(response))
                    case let .failure(error):
                        PP.error("[Message] [Send]: Failure - \(error)")
                        observer(.failure(error))
                    }
                }
            }

            return Disposables.create()
        }
    }
}


class ReadMessageInteractor: GRPCErrorUseCase<Message, MessagesReadResponse> {

    override func job(params: Message) -> Single<MessagesReadResponse> {
        Single.create { [weak self] observer -> Disposable in
            
            guard let `self` = self else { return Disposables.create() }
            AppSettingsImpl.shared.messageService.read(params.readRequest, callOptions: .default()).response.whenComplete { result in
                switch result {
                case let .success(response):
                    observer(.success(response))
                case let .failure(error):
                    observer(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}

class DeliveredMessageInteractor: GRPCErrorUseCase<Message, MessagesDeliveredResponse> {

    override func job(params: Message) -> Single<MessagesDeliveredResponse> {
        Single.create { [weak self] observer -> Disposable in
            
            guard let `self` = self else { return Disposables.create() }
            AppSettingsImpl.shared.messageService.delivered(params.deliveredRequest, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case let .success(response):
                        observer(.success(response))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}

private extension Message {
    var readRequest: MessagesReadRequest {
        return .with({
            $0.chatID = receiver.chatID
            $0.readTime = Date().nanosec
            $0.maxSeqNumber = UInt64.init(self.seqNumber)
        })
    }
    
    var deliveredRequest:MessagesDeliveredRequest {
        return .with({
            $0.chatID = receiver.chatID
            $0.maxSeqNumber = UInt64.init(self.seqNumber)
        })
    }
}
