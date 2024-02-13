import Foundation

// MARK: - IncomingCallViewInterface

extension IncomingCallViewController: IncomingCallViewInterface {
    
    func connectRoom(with callInfo: CallInformation) {
        room.connect(callInfo.host, callInfo.accessToken).then { [weak self] room in
            guard let self, let status = presenter?.getCallStatus() else { return }
            if case .incoming = status {
                configureStartCall()
            }
            if callInfo.video && actionStackView.cameraButton.isSelected {
                setVideoCallIfPossible(enabled: callInfo.video)
            }
            if actionStackView.microButton.isSelected {
                setMicrophoneIfPossible(enabled: actionStackView.microButton.isSelected)
            }
        }.catch { error in
            self.dismiss(animated: true)
        }
    }

    func disconnectRoom() {
        room.disconnect().then({[weak self] () in
            self?.dismissPage()
        }).catch { [weak self] error  in
            self?.dismissPage()
        }
    }
    
    func dispay(view contact: ContactDisplayable) {
        infoView.confige(view: contact)
    }
    
    private func dismissPage() {
        if let presentingViewController {
            presentingViewController.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

}
