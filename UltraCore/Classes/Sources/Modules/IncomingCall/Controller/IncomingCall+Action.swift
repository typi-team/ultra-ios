import UIKit
import CallKit
import AVFAudio
import LiveKitClient

// MARK: - IncomingCallActionViewDelegate

extension IncomingCallViewController: IncomingCallActionViewDelegate {
    
    func view(_ view: IncomingCallActionView, switchCameraButtonDidTap button: UIButton) {
        let localVideoTrack = presenter?.getLocalParticipant()?.firstCameraVideoTrack as? LocalVideoTrack
        let cameraCapturer = localVideoTrack?.capturer as? CameraCapturer
        let remoteParticipant = presenter?.getRemoteParticipant()
        let videoView: VideoView
        if remoteParticipant?.isCameraEnabled() ?? false {
            videoView = localVideoView
        } else {
            videoView = remoteVideoView
        }
        videoView.applyBlurEffect()
        Task {
            do {
                try await cameraCapturer?.switchCameraPosition()
            } catch {
                
            }
        }
        button.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            videoView.removeBlurEffect()
            button.isEnabled = true
        }
    }
    
    func view(_ view: IncomingCallActionView, answerButtonDidTap button: UIButton) {
        answerToCall()
    }
    
    func view(_ view: IncomingCallActionView, mouthpieceButtonDidTap button: UIButton) {
        setSpeaker(button.isSelected)
    }
    
    func view(_ view: IncomingCallActionView, microButtonDidTap button: UIButton) {
        setMicrophoneIfPossible(enabled: button.isSelected)
    }
    
    func view(_ view: IncomingCallActionView, cameraButtonDidTap button: UIButton) {
        let cameraEnabled = button.isSelected
        if cameraEnabled {
            actionStackView.setAsActiveCamera()
            setSpeaker(true)
        } else {
            setSpeaker(AudioManager.shared.isSpeakerOutputPreferred)
            setSpeakerButtonEnabled(AudioManager.shared.isSpeakerOutputPreferred)
            actionStackView.setAsActiveAudio()
        }
        setVideoCallIfPossible(enabled: cameraEnabled)
    }
    
    func view(_ view: IncomingCallActionView, endCallButtonDidTap button: UIButton) {
        cancelCall()
    }
    
    func answerToCall() {
        guard let callStatus = presenter?.getCallStatus(), !(presenter?.getIsConnected() ?? false) else { return }
        if callStatus.callInfo.video {
            actionStackView.setAsActiveCamera()
            remakeInfoViewConstraints(isVideo: true)
        } else {
            actionStackView.setAsActiveAudio()
        }
        presenter?.answerCall()
    }
    
    func cancelCall() {
        infoView.setDuration(text: CallStrings.cancel.localized)
        PP.debug("[CALL] cancell call")
        presenter?.cancel()
    }
    
}
