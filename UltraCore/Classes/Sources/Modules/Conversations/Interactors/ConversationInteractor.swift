//
//  ConversationInteractor.swift
//  UltraCore
//
//  Created by Typi on 12.04.2024.
//

import RxSwift

class ConversationInteractor: GRPCErrorUseCase<String, Chat> {
    
    override func executeSingle(params: String) -> Single<Chat> {
        return Single<Chat>.create { [unowned self] single in
            let request = GetChatRequest.with { req in
                req.id = params
            }
            AppSettingsImpl.shared.conversationService.getByID(request, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case .success(let response):
                        single(.success(response.chat))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
