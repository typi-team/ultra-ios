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


class InternetConnectionManager {
    static let shared = InternetConnectionManager()

    private let reachability = try! Reachability()

    private let internetConnectionSubject = BehaviorSubject<Bool>(value: true)
    var isInternetAvailable: Observable<Bool> {
        return internetConnectionSubject.asObservable()
    }

    private init() {
        setupReachability()
    }

    private func setupReachability() {
        reachability.whenReachable = { [weak self] _ in
            self?.internetConnectionSubject.onNext(true)
        }

        reachability.whenUnreachable = { [weak self] _ in
            self?.internetConnectionSubject.onNext(false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start reachability notifier")
        }
    }

    deinit {
        reachability.stopNotifier()
    }
}
