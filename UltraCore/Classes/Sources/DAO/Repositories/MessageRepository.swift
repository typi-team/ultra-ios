//
//  MessageRepository.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import RealmSwift
import RxSwift


protocol MessageRepository: AnyObject {
    func save(message: Message) -> Single<Void>
    func update(message: Message) -> Single<Bool>
    func messages(chatID: String) -> Observable<Results<DBMessage>>
}

class MessageRespositoryImpl {

    fileprivate let messageService: MessageDBService

    init(messageService: MessageDBService) {
        self.messageService = messageService
    }
}

extension MessageRespositoryImpl : MessageRepository  {
    func save(message: Message) -> Single<Void> {
        return self.messageService.save(message: message)
    }

    func update(message: Message) -> Single<Bool> {
        return self.messageService.update(message: message)
    }

    func messages(chatID: String) -> Observable<RealmSwift.Results<DBMessage>> {
        return self.messageService.messages(chatID: chatID)
    }
}
