import RxSwift
import Foundation

final class ReachabilityInteractor: UseCase<Void, Void> {
    
    // MARK: - Properties
    
    private let reachability = try? Reachability()

    // MARK: - Init
    
    override func execute(params: Void) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            self.reachability?.whenReachable = { _ in
                observer.onNext(())
            }
            try? self.reachability?.startNotifier()
            return Disposables.create()
        }
    }
    
}
