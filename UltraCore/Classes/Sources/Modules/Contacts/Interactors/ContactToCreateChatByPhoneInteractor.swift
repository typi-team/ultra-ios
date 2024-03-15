//
//  ContactToCreateChatByPhoneInteractor.swift
//  UltraCore
//
//  Created by Slam on 9/28/23.
//
import RxSwift
import Foundation

class ContactToCreateChatByPhoneInteractor: GRPCErrorUseCase<IContact, CreateChatByPhoneResponse> {
    final let integrateService: IntegrationServiceClientProtocol
    
     init(integrateService: IntegrationServiceClientProtocol) {
         self.integrateService = integrateService
    }
    
    override func job(params: IContact) -> Single<CreateChatByPhoneResponse> {
        PP.debug("Attempt to create chat by phone for \(params.identifier)")
        return Single.create(subscribe: { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }

            self.integrateService.createChatByPhone(.with({
                $0.firstname = params.firstname
                $0.phone = params.identifier
            }), callOptions: .default())
            .response
            .whenComplete({ result in
                switch result {
                case let .success(response):
                    PP.debug("Created chat by phone for \(params.identifier)")
                    observer(.success(response))
                case let .failure(error):
                    PP.debug("Failed to create chat by phone for \(params.identifier); error - \(error.localeError)")
                    observer(.failure(error))
                }

            })

            return Disposables.create()
        })
    }
}

class ContactToConversationInteractor: GRPCErrorUseCase<IContact, Conversation?> {
    final let contactToCreateChatByPhoneInteractor: ContactToCreateChatByPhoneInteractor
    final let contactByUserIdInteractor: ContactByUserIdInteractor
    final let contactDBService: ContactDBService

    init(contactDBService: ContactDBService,
         contactsService: ContactServiceClientProtocol,
         integrateService: IntegrationServiceClientProtocol) {
             self.contactDBService = contactDBService
             self.contactByUserIdInteractor = ContactByUserIdInteractor(delegate: nil, contactsService: contactsService)
        self.contactToCreateChatByPhoneInteractor = ContactToCreateChatByPhoneInteractor.init(integrateService: integrateService)
    }

    override func job(params: IContact) -> Single<Conversation?> {
        self.contactToCreateChatByPhoneInteractor.executeSingle(params: params)
            .flatMap({ [weak self] contactToCreateChat in
                guard let `self` = self else { throw NSError.selfIsNill}
                return self.contactByUserIdInteractor.executeSingle(params: contactToCreateChat.userID)
                    .flatMap({ [weak self] contact in
                        guard let `self` = self else { throw NSError.selfIsNill}
                        return self.contactDBService.save(contact: contact)
                            .map({ 
                                ConversationImpl(
                                    contact: contact,
                                    idintification: contactToCreateChat.chatID,
                                    addContact: contactToCreateChat.chat.settings.addContact,
                                    seqNumber: contactToCreateChat.chat.messageSeqNumber
                                )
                            })
                    })
            })
    }
}
