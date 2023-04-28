//
//  SendMessageInteractor.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import Foundation
import RxSwift

class SendMessageInteractor: UseCase<MessageSendRequest, MessageSendResponse> {
    final let messageService: MessageServiceClientProtocol

    init(messageService: MessageServiceClientProtocol) {
        self.messageService = messageService
    }

    override func executeSingle(params: MessageSendRequest) -> Single<MessageSendResponse> {
        return Single.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }

            self.messageService.send(params, callOptions: .default()).response.whenComplete { result in
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
