import RxSwift
import UIKit

class MakeVibrationInteractor: UseCase<UIImpactFeedbackGenerator.FeedbackStyle, Void> {

    override func executeSingle(params: UIImpactFeedbackGenerator.FeedbackStyle) -> Single<Void> {
        Single<Void>.create { observer -> Disposable in
            UIImpactFeedbackGenerator(style: params).impactOccurred()
            return Disposables.create()
        }
    }

}
