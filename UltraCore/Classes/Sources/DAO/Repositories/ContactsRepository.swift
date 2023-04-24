//
//  ContactsRepository.swift
//  UltraCore
//
//  Created by Slam on 4/24/23.
//
import RealmSwift

import Foundation

protocol ContactsRepository {
    func contacts() -> Observable<Results<Contact>>
    func getById(_ id: String) -> Single<Contact>
    func save(_ contact: Contact) -> Completable
    func delete(_ contact: Contact) -> Completable
}

