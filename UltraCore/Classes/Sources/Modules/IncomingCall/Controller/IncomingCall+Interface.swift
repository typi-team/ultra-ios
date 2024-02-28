import Foundation
import LiveKitClient
import AVFoundation

// MARK: - IncomingCallViewInterface

extension IncomingCallViewController: IncomingCallViewInterface {
    
    func showConnectedRoom(with callStatus: CallStatus) {
        if case .incoming = callStatus {
            updateForStartCall()
        }
        if callStatus.callInfo.video && actionStackView.cameraButton.isSelected {
            setVideoCallIfPossible(enabled: callStatus.callInfo.video)
        }
        if actionStackView.microButton.isSelected {
            setMicrophoneIfPossible(enabled: actionStackView.microButton.isSelected)
        }
        if !callStatus.callInfo.video {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.setSpeaker(false)
            }
        }
    }
    
    func setCameraEnabled(_ enabled: Bool) {
        if enabled {
            actionStackView.setAsActiveCamera()
        } else {
            actionStackView.setAsActiveAudio()
        }
    }
    
    func setMicEnabled(_ enabled: Bool) {
        actionStackView.microButton.isSelected = enabled
    }
    
    func dispay(view contact: ContactDisplayable) {
        infoView.confige(view: contact)
    }
    
    func updateParticipantTrack(remote: LiveKitClient.RemoteParticipant?, local: LiveKitClient.LocalParticipant?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if remote?.isCameraEnabled() ?? false && local?.isCameraEnabled() ?? false {
                remoteVideoView.track = remote?.videoTracks.first?.track as? VideoTrack
                localVideoView.track = local?.videoTracks.first?.track as? VideoTrack
                remoteVideoView.isHidden = false
                localVideoView.isHidden = false
                remakeInfoViewConstraints(isVideo: true)
                actionStackView.setAsActiveCamera()
            } else {
                if local?.isCameraEnabled() ?? false {
                    remoteVideoView.track = local?.videoTracks.first?.track as? VideoTrack
                    remoteVideoView.isHidden = false
                    localVideoView.isHidden = true
                    remakeInfoViewConstraints(isVideo: true)
                    actionStackView.setAsActiveCamera()
                } else {
                    remoteVideoView.isHidden = true
                    localVideoView.isHidden = true
                    remakeInfoViewConstraints(isVideo: false)
                    actionStackView.setAsActiveAudio()
                }
            }
        }
    }
    
    func updateForStartCall() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            infoView.hidePhoneNumber()
            subscribeToTimer()
        }
    }
    
    func showConnectionStatus(_ status: String) {
        infoView.setDuration(text: status)
    }
    
    private func dismissPage() {
        if let presentingViewController {
            presentingViewController.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func setVideoCallIfPossible(enabled: Bool) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presenter?.setCamera(enabled: enabled)
            remakeInfoViewConstraints(isVideo: enabled)
        case .denied, .restricted:
            showSettingAlert(from: CallStrings.errorAccessToCamera.localized, with: CallStrings.errorAccessTitle.localized)
            deniedCameraPermission()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if granted {
                        presenter?.setCamera(enabled: enabled)
                        remakeInfoViewConstraints(isVideo: enabled)
                    } else {
                        deniedCameraPermission()
                    }
                }
            }
        default: break
        }
    }
    
    func setMicrophoneIfPossible(enabled: Bool) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            presenter?.setMicrophone(enabled: enabled)
        case .denied:
            showSettingAlert(from: CallStrings.errorAccessToMicrophone.localized, with: CallStrings.errorAccessTitle.localized)
            actionStackView.microButton.isSelected = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if granted {
                        presenter?.setMicrophone(enabled: enabled)
                    } else {
                        actionStackView.microButton.isSelected = false
                    }
                }
            }
        default: break
        }
    }
    
    private func deniedCameraPermission() {
        actionStackView.cameraButton.isSelected = false
        actionStackView.mouthpieceButton.isSelected = false
        actionStackView.setAsActiveAudio()
        remakeInfoViewConstraints(isVideo: false)
    }

}
