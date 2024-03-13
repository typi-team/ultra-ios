import Foundation
import RxSwift

extension IncomingCallViewController {
    
    func subscribeToTimer() {
        guard RoomManager.shared.timerIsRunning else {
            return
        }
        RoomManager.shared
            .timerTextObservable
            .startWith(RoomManager.shared.currentTimerValue)
            .subscribe { [weak self] text in
                DispatchQueue.main.async {
                    self?.infoView.setDuration(text: text)
                }
            }
            .disposed(by: disposeBag)
    }
    
}
