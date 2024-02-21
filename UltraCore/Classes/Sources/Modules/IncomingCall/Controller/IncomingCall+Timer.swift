import Foundation

extension IncomingCallViewController {
    
    func startTimer() {
        guard displayLink == nil else { return }

        displayLink = CADisplayLink(target: self, selector: #selector(displayRefreshed))
        displayLink?.add(to: .main, forMode: .default)
        date = Date()
    }

    @objc
    private func displayRefreshed(displayLink: CADisplayLink) {
        guard let startDate = date, (presenter?.getIsConnected() ?? false) else { return }
        let elepsadeTime = Int(Date().timeIntervalSince(startDate).rounded(.toNearestOrEven))
        infoView.setDuration(text: timeFormatted(elepsadeTime))
    }

    private func timeFormatted(_ second: Int) -> String {
        let seconds: Int = second % 60
        let minutes: Int = (second / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func endTimer() {
        displayLink?.invalidate()
        displayLink = nil
        date = nil
    }
    
}
