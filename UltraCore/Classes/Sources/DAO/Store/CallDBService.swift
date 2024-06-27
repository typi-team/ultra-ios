//
//  CallDBService.swift
//  UltraCore
//
//  Created by Typi on 27.06.2024.
//

import RealmSwift
import RxSwift

class CallDBService {
    
    func callUpdates(for room: String) -> Observable<CallStatusEnum> {
        let realm = Realm.myRealm()
        guard let call = realm.object(ofType: DBCallMessage.self, forPrimaryKey: room) else {
            return .just(.callStatusCreated)
        }
        let callStatus = CallStatusEnum(rawValue: call.status) ?? .callStatusCreated
        return Observable.create { observer in
            let notificationToken = call.observe(keyPaths: ["status"]) { change in
                switch change {
                case .change(let object, let properties):
                    for property in properties {
                        guard property.name == "status", let status = property.newValue as? Int else {
                            continue
                        }
                        observer.onNext(.init(rawValue: status) ?? .callStatusCreated)
                    }
                case .error(let error):
                    observer.onError(error)
                case .deleted:
                    observer.onError(NSError.objectsIsNill)
                }
            }
            
            return Disposables.create {
                notificationToken.invalidate()
            }
        }
        .startWith(callStatus)
    }
    
}
