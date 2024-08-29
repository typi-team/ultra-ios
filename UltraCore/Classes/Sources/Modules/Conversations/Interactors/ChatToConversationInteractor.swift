//
//  ChatToConversationInteractor.swift
//  UltraCore
//
//  Created by Typi on 13.05.2024.
//

import Foundation
import RxSwift
import RealmSwift

struct ChatToConversationParams {
    let chat: Chat
    let imagePath: String?
}

class ChatToConversationInteractor: GRPCErrorUseCase<ChatToConversationParams, Void> {
    
    private let contactByUserIdInteractor: ContactByUserIdInteractor
    private let contactDBService: ContactDBService
    private let disposeBag = DisposeBag()
    
    init(contactByUserIdInteractor: ContactByUserIdInteractor, contactDBService: ContactDBService) {
        self.contactByUserIdInteractor = contactByUserIdInteractor
        self.contactDBService = contactDBService
    }
    
    override func executeSingle(params: ChatToConversationParams) -> Single<Void> {
        return Single<Void>.create { single in
            Realm.realmQueue.async { [weak self] in
                guard let self = self else {
                    single(.failure(NSError.objectsIsNill))
                    return
                }
                guard let realm = Realm.myRealm() else {
                    single(.failure(UltraCoreSettings.realmError ?? NSError.objectsIsNill))
                    return
                }
                if let conversation = realm.object(ofType: DBConversation.self, forPrimaryKey: params.chat.chatID) {
                    do {
                        try realm.write {
                            conversation.imagePath = params.imagePath ?? ""
                            conversation.title = params.chat.title
                            if params.chat.properties["is_assistant"] == "true" {
                                conversation.isAssistant = true
                            }
                            PP.debug("Saving imagepath - \(params.imagePath); title - \(params.chat.title) for existing chatID - \(params.chat.chatID)")
                            realm.create(DBConversation.self, value: conversation, update: .all)
                        }
                        single(.success(()))
                    } catch {
                        single(.failure(error))
                    }
                    
                    return
                }
                
                let requests = params.chat.members
                    .map { $0.id }
                    .filter {
                        $0 != AppSettingsImpl.shared.appStore.userID()
                    }
                    .map { self.contactByUserIdInteractor.executeSingle(params: $0).asObservable() }
                Observable.zip(requests)
                    .flatMap { [weak self] contacts -> Observable<[DBContact]> in
                        guard let self = self else {
                            return Observable.empty()
                        }
                        PP.debug("Got contacts - \(contacts.map { "\($0.firstname) \($0.lastname) \($0.phone)" }) for chatID - \(params.chat.chatID) chatTitle - \(params.chat.title)")
                        let contactRequests = contacts.map {
                            self.contactDBService.save(contact: $0).asObservable()
                        }
                        return Observable.zip(contactRequests)
                    }
                    .flatMap { contacts -> Observable<Void> in
                        return Observable.create { observer in
                            Realm.realmQueue.async {
                                guard let localRealm = Realm.myRealm() else {
                                    observer.onError(UltraCoreSettings.realmError ?? NSError.objectsIsNill)
                                    return
                                }
                                if let conversation = localRealm.object(ofType: DBConversation.self, forPrimaryKey: params.chat.chatID) {
                                    do {
                                        try localRealm.write {
                                            conversation.imagePath = params.imagePath ?? ""
                                            conversation.title = params.chat.title
                                            localRealm.create(DBConversation.self, value: conversation, update: .all)
                                        }
                                        observer.onNext(())
                                        observer.onCompleted()
                                    } catch {
                                        observer.onError(error)
                                    }
                                    return
                                }
                                
                                do {
                                    try localRealm.write {
                                        let conv = ConversationImpl(
                                            title: params.chat.title,
                                            contacts: contacts.map { $0.toInterface() },
                                            idintification: params.chat.chatID,
                                            addContact: params.chat.settings.addContact,
                                            seqNumber: params.chat.messageSeqNumber,
                                            callAllowed: params.chat.settings.callAllowed
                                        )
                                        let conversation = localRealm.create(DBConversation.self, value: DBConversation(conversation: conv, contacts: contacts))
                                        conversation.conversationType = params.chat.chatType.rawValue
                                        conversation.imagePath = params.imagePath ?? ""
                                        if params.chat.properties["is_assistant"] == "true" {
                                            conversation.isAssistant = true
                                        }
                                        PP.debug("Saving imagepath - \(params.imagePath); title - \(params.chat.title) for new chatID - \(params.chat.chatID)")
                                    }
                                    observer.onNext(())
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                }
                            }
                            
                            return Disposables.create()
                        }
                        
                    }
                    .subscribe(onNext: { _ in
                        single(.success(()))
                    }, onError: { error in
                        single(.failure(error))
                    })
                    .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }

    }
    
}
