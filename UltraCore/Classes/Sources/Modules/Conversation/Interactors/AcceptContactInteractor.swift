//
//  AcceptContactInteractor.swift
//  UltraCore
//
//  Created by Typi on 07.03.2024.
//

import Foundation
import RxSwift

class AcceptContactInteractor: GRPCErrorUseCase<String, Void> {
    private let contactService: ContactServiceClientProtocol
    
    init(contactService: ContactServiceClientProtocol) {
        self.contactService = contactService
    }
    
    override func job(params: String) -> Single<Void> {
        return Single<Void>.create { [unowned self] single in
            let request = AcceptContactRequest.with {
                $0.userID = params
            }
            self.contactService.acceptContact(request, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case .success:
                        single(.success(()))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}

