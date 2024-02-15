import UIKit
import CallKit
import AVFAudio
import LiveKitClient

// MARK: - IncomingCallActionViewDelegate

extension IncomingCallViewController: IncomingCallActionViewDelegate {
    
    func view(_ view: IncomingCallActionView, switchCameraButtonDidTap button: UIButton) {
        let localVideoTrack = room.localParticipant?.firstCameraVideoTrack as? LocalVideoTrack
        let cameraCapturer = localVideoTrack?.capturer as? CameraCapturer
        let remoteParticipant = room.remoteParticipants.first?.value
        let videoView: VideoView
        if remoteParticipant?.isCameraEnabled() ?? false {
            videoView = localVideoView
        } else {
            videoView = remoteVideoView
        }
        videoView.applyBlurEffect()
        cameraCapturer?.switchCameraPosition()
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
            actionStackView.setAsActiveAudio()
        }
        setVideoCallIfPossible(enabled: cameraEnabled)
    }
  
    func view(_ view: IncomingCallActionView, cancelButtonDidTap button: UIButton) {
        cancelCall()
    }
    
    func view(_ view: IncomingCallActionView, rejectButtonDidTap button: UIButton) {
        rejectCall()
    }
    
    func answerToCall() {
        guard let callStatus = presenter?.getCallStatus(), room.connectionState == .disconnected() else { return }
        if callStatus.callInfo.video {
            actionStackView.setAsActiveCamera()
            setSpeaker(true)
            remakeInfoViewConstraints(isVideo: true)
        } else {
            actionStackView.setAsActiveAudio()
        }
        connectRoom(with: callStatus.callInfo)
        UltraVoIPManager.shared.startCall()
    }
    
    func cancelCall() {
        endTimer()
        infoView.setDuration(text: CallStrings.cancel.localized)
        presenter?.cancel()
        UltraVoIPManager.shared.endCall()
    }
    
    func rejectCall() {
        infoView.setDuration(text: CallStrings.reject.localized)
        presenter?.reject()
        UltraVoIPManager.shared.endCall()
    }
    
}
