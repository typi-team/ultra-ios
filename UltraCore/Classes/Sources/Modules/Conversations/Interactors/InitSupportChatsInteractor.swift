//
//  InitSupportChatsInteractor.swift
//  UltraCore
//
//  Created by Typi on 13.05.2024.
//

import Foundation
import RxSwift

class InitSupportChatsInteractor: GRPCErrorUseCase<InitSupportChatsRequest, InitSupportChatsResponse> {
    
    private let supportService: SupportServiceClientProtocol
    
    init(supportService: SupportServiceClientProtocol) {
        self.supportService = supportService
    }
    
    override func executeSingle(params: InitSupportChatsRequest) -> Single<InitSupportChatsResponse> {
        return Single<InitSupportChatsResponse>.create { [unowned self] single in
            self.supportService.initSupportChats(params, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case .success(let response):
                        single(.success(response))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
}
