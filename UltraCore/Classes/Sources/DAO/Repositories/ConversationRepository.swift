//
//  ConversationRepository.swift
//  UltraCore
//
//  Created by Slam on 5/2/23.
//

import RxSwift
import RealmSwift

protocol ConversationRepository {
    func createIfNotExist(from message: Message) -> Single<Void>
    func conversations() -> Observable<[Conversation]>
    func update(addContact: Bool, for conversationID: String) -> Single<Void>
    func callAllowed(for conversationID: String) -> Observable<Bool>
}

class ConversationRepositoryImpl {
    
    fileprivate let conversationService: ConversationDBService
    
    init(conversationService: ConversationDBService) {
        self.conversationService = conversationService
        
        let realm = Realm.myRealm()
        print(realm?.configuration.fileURL?.absoluteString)
//        try! realm.write({ realm.deleteAll() })
    }
}

extension ConversationRepositoryImpl: ConversationRepository {
    func createIfNotExist(from message: Message) -> Single<Void> {
        return self.conversationService.createIfNotExist(from: message)
    }
    
    func conversations() -> Observable<[Conversation]> {
        return self.conversationService.conversations()
    }
    
    func update(addContact: Bool, for conversationID: String) -> Single<Void> {
        conversationService.update(addContact: addContact, id: conversationID)
    }
    
    func callAllowed(for conversationID: String) -> Observable<Bool> {
        conversationService.callAllowedObservable
            .filter { $0.0 == conversationID }
            .map(\.1)
    }
}
