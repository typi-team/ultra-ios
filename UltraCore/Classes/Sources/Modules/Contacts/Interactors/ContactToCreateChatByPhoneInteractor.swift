//
//  ContactToCreateChatByPhoneInteractor.swift
//  UltraCore
//
//  Created by Slam on 9/28/23.
//
import RxSwift
import Foundation

class ContactToCreateChatByPhoneInteractor: UseCase<IContact, CreateChatByPhoneResponse> {
    final let integrateService: IntegrationServiceClientProtocol
    
     init(integrateService: IntegrationServiceClientProtocol) {
         self.integrateService = integrateService
    }
    
    override func executeSingle(params: IContact) -> Single<CreateChatByPhoneResponse> {
        Single.create(subscribe: { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }

            self.integrateService.createChatByPhone(.with({
                $0.firstname = params.firstname
                $0.phone = params.identifier
            }), callOptions: .default())
            .response
            .whenComplete({ result in
                switch result {
                case let .success(response):
                    observer(.success(response))
                case let .failure(error):
                    observer(.failure(error))
                }

            })

            return Disposables.create()
        })
    }
}

class ContactToConversationInteractor: UseCase<IContact, Conversation?> {
    final let contactToCreateChatByPhoneInteractor: ContactToCreateChatByPhoneInteractor
    final let contactByUserIdInteractor: ContactByUserIdInteractor
    final let contactRepository: ContactsRepository

    init(contactRepository: ContactsRepository,
         contactsService: ContactServiceClientProtocol,
         integrateService: IntegrationServiceClientProtocol) {
             self.contactRepository = contactRepository
             self.contactByUserIdInteractor = ContactByUserIdInteractor(delegate: nil, contactsService: contactsService)
        self.contactToCreateChatByPhoneInteractor = ContactToCreateChatByPhoneInteractor.init(integrateService: integrateService)
    }

    override func executeSingle(params: IContact) -> Single<Conversation?> {
        
        return self.contactToCreateChatByPhoneInteractor.executeSingle(params: params)
            .flatMap({ [weak self] contactToCreateChat in
                guard let `self` = self else { throw NSError.selfIsNill}
                return self.contactByUserIdInteractor.executeSingle(params: contactToCreateChat.userID)
                    .flatMap({ [weak self] contact in
                        guard let `self` = self else { throw NSError.selfIsNill}
                        return self.contactRepository.save(contact: .init(from: contact))
                            .map({self.contactRepository.contact(id: contactToCreateChat.userID)})
                            .map({ $0 != nil ? ConversationImpl(contact: $0!, idintification: contactToCreateChat.chatID): nil })
                    })
            })
    }
}
