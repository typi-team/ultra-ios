//
//  UpdateRepository.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import Foundation

protocol UpdateRepository: AnyObject {
    func setupSubscription()
}

class UpdateRepositoryImpl {
    
    private let update: UpdatesServiceClientProtocol
    fileprivate let contactService: ContactDBService
    fileprivate let messageService: MessageDBService
    fileprivate let conversationService: ConversationDBService
    fileprivate let contactByIDInteractor: UseCase<String, Contact>
    
    
    init(messageService: MessageDBService,
         contactService: ContactDBService,
         update: UpdatesServiceClientProtocol,
         userByIDInteractor: UseCase<String, Contact>,
         conversationService: ConversationDBService) {
        self.update = update
        self.messageService = messageService
        self.contactService = contactService
        self.contactByIDInteractor = userByIDInteractor
        self.conversationService = conversationService
    }
}



extension UpdateRepositoryImpl: UpdateRepository {
    
    func setupSubscription() {
        
        let state: ListenRequest = .with { $0.localState = .with { $0.state = 0 } }
        let call = self.update.listen(state, callOptions: .default()) { [weak self] response in
            guard let `self` = self else { return }
            response.updates.forEach { update in
                if !update.message.text.isEmpty {
                    let contactID = update.message.sender.userID
                    let contact = self.contactService.contact(id: contactID)
                    if contact == nil {
                        _ = self.contactByIDInteractor
                            .executeSingle(params: contactID)
                            .flatMap({ self.contactService.save(contact: DBContact(from: $0)) })
                            .flatMap({ _ in self.conversationService.createIfNotExist(from: update.message) })
                            .flatMap({ self.messageService.update(message: update.message) })
                            .subscribe()
                            
                    }else {
                        self.conversationService
                            .createIfNotExist(from: update.message)
                            .flatMap({ self.messageService.update(message: update.message) })
                            .subscribe()
                            .dispose()
                    }

                }
            }
        }
        call.status.whenComplete { status in
            print(status)
        }
    }
}
