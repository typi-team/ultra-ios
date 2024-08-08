//
//  SyncContactsInteractor.swift
//  UltraCore
//
//  Created by Slam on 4/24/23.
//
import RxSwift
import Foundation

class SyncContactsInteractor: UseCase<ContactsImportRequest, ContactImportResponse> {
    
    override func executeSingle(params: ContactsImportRequest) -> Single<ContactImportResponse> {
        return Single.create { observer -> Disposable in
            AppSettingsImpl.shared.contactsService.import(params,callOptions:  .default())
                .response
                .whenComplete { result in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
}
