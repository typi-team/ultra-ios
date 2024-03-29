//
//  BlockContactInteractor.swift
//  UltraCore
//
//  Created by Slam on 1/3/24.
//

import Foundation
import RxSwift

typealias BlockParam = (userID: String, block: Bool)

class BlockContactInteractor: GRPCErrorUseCase<BlockParam, Void> {
    final let userService: UserServiceClientProtocol
    final let contactDBService: ContactDBService
    var isFirstCall = true

    init(userService: UserServiceClientProtocol,
         contactDBService: ContactDBService) {
        self.userService = userService
        self.contactDBService = contactDBService
    }

    override func job(params: BlockParam) -> Single<Void> {
        return Single<Void>.create { [weak self] observer in
            guard let `self` = self else {
                return Disposables.create()
            }

            if !params.block {
                self.userService.unblockUser(.with({
                    $0.userID = params.userID
                }), callOptions: .default())
                    .response.whenComplete({ result in

                        switch result {
                        case .success:
                            observer(.success(()))
                        case let .failure(error):
                            observer(.failure(error))
                        }
                    })
            } else {
                self.userService.blockUser(.with({
                    $0.userID = params.userID
                }), callOptions: .default())
                    .response.whenComplete({ result in
                        switch result {
                        case .success:
                            observer(.success(()))
                        case let .failure(error):
                            observer(.failure(error))
                        }
                    })
            }
            return Disposables.create()
        }.flatMap({ [weak self] _ in
            guard let `self` = self else {
                throw NSError.selfIsNill
            }
            return self.contactDBService.block(user: params.userID, blocked: params.block)
        })
    }
}
