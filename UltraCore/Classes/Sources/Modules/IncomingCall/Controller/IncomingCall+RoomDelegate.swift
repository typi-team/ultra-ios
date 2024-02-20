import LiveKitClient
import AVFoundation

// MARK: - RoomDelegate

extension IncomingCallViewController: RoomDelegate {
    
    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {
        PP.debug("[CALL] connection state - \(connectionState.desctiption) for room - \(room.sid)")
        switch connectionState {
        case .reconnecting, .connecting:
            DispatchQueue.main.async { [weak self] in
                self?.infoView.setDuration(text: connectionState.desctiption)
            }
        default:
            break
        }
    }
    
    func room(_ room: Room, participantDidJoin participant: RemoteParticipant) {
        configureStartCall()
    }
    
    func room(_ room: Room, localParticipant: LocalParticipant, didPublish publication: LocalTrackPublication) {
        guard publication.track is VideoTrack else { return }
        configureParticipantTrack()
    }
 
    func room(_ room: Room, participant: RemoteParticipant, didSubscribe publication: RemoteTrackPublication, track: Track) {
        guard track is VideoTrack else { return }
        configureParticipantTrack()
    }
    
    func room(_ room: Room, participant: Participant, didUpdate publication: TrackPublication, muted: Bool) {
        guard publication.track is VideoTrack else { return }
        configureParticipantTrack()
    }
    
    private func configureParticipantTrack() {
        let remoteParticipant = room.remoteParticipants.first?.value
        let localParticipant = room.localParticipant
                
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if remoteParticipant?.isCameraEnabled() ?? false && localParticipant?.isCameraEnabled() ?? false {
                remoteVideoView.track = remoteParticipant?.videoTracks.first?.track as? VideoTrack
                localVideoView.track = localParticipant?.videoTracks.first?.track as? VideoTrack
                remoteVideoView.isHidden = false
                localVideoView.isHidden = false
                remakeInfoViewConstraints(isVideo: true)
                actionStackView.setAsActiveCamera()
            } else {
                if localParticipant?.isCameraEnabled() ?? false {
                    remoteVideoView.track = localParticipant?.videoTracks.first?.track as? VideoTrack
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
        
    func setVideoCallIfPossible(enabled: Bool) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            room.localParticipant?.setCamera(enabled: enabled)
            remakeInfoViewConstraints(isVideo: enabled)
        case .denied, .restricted:
            showSettingAlert(from: CallStrings.errorAccessToCamera.localized, with: CallStrings.errorAccessTitle.localized)
            deniedCameraPermission()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if granted {
                        room.localParticipant?.setCamera(enabled: enabled)
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
            room.localParticipant?.setMicrophone(enabled: enabled)
        case .denied:
            showSettingAlert(from: CallStrings.errorAccessToMicrophone.localized, with: CallStrings.errorAccessTitle.localized)
            actionStackView.microButton.isSelected = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if granted {
                        room.localParticipant?.setMicrophone(enabled: enabled)
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
        setSpeaker(false)
    }
    
}
