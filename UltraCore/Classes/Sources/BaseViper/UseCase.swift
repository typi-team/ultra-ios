import Foundation
import RxSwift

class UseCase<P, R> {
    func execute(params: P) -> Observable<R> {
        PP.error("execute(params:) has not been implemented")
        return .error(NSError.objectsIsNill)
    }
    func executeCompletable(params: P) -> Completable {
        PP.error("executeCompletable(params:) has not been implemented")
        return .error(NSError.objectsIsNill)
    }
    func executeSingle(params: P) -> Single<R> {
        PP.error("executeSingle(params:) has not been implemented")
        return .error(NSError.objectsIsNill)
    }

    func executeMaybe(params: P) -> Maybe<R> {
        PP.error("executeMaybe(params:) has not been implemented")
        return .error(NSError.objectsIsNill)
    }
    
    deinit {
        PP.info("Deinit \(String.init(describing: self))")
    }
}
