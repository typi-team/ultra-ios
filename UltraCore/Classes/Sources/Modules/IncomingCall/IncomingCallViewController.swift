//
//  IncomingCallViewController.swift
//  Pods
//
//  Created by Slam on 9/4/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import LiveKitClient
import AVFAudio
import AVFoundation

final class IncomingCallViewController: BaseViewController<IncomingCallPresenterInterface> {
    
    fileprivate lazy var room = Room(delegate: self)
    
    fileprivate var displayLink: CADisplayLink?
    
    fileprivate var date: Date?
    
    fileprivate let audioQueue = DispatchQueue(label: "audio")
    
    fileprivate lazy var localVideoView: VideoView = .init({
        $0.isHidden = true
        $0.cornerRadius = kLowPadding
    })

    fileprivate lazy var remoteVideoView: VideoView = .init({
        $0.isHidden = true
        $0.cornerRadius = kLowPadding
    })

    fileprivate lazy var style: CallPageStyle = UltraCoreStyle.callingConfig

    fileprivate lazy var infoView = IncomingCallInfoView(style: style)

    fileprivate lazy var actionStackView = IncomingCallActionView(style: style, delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = style.background.color
    }

    override func setupViews() {
        super.setupViews()

        view.addSubview(remoteVideoView)
        view.addSubview(infoView)
        view.addSubview(actionStackView)
        view.addSubview(localVideoView)
    }

    override func setupConstraints() {
        super.setupConstraints()

        actionStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-54)
            make.left.equalToSuperview().offset(kHeadlinePadding)
            make.right.equalToSuperview().offset(-kHeadlinePadding)
            make.height.equalTo(52)
        }
        infoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY).offset(-36)
        }
        remoteVideoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        localVideoView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(31)
            make.bottom.equalTo(actionStackView.snp.top).offset(-32)
            make.width.equalTo(90)
            make.height.equalTo(150)
        }
    }

    override func setupInitialData() {
        super.setupInitialData()

        presenter?.viewDidLoad()
        guard let status = presenter?.getCallStatus() else { return }
        actionStackView.configure(status: status)
        switch status {
        case .incoming:
            infoView.setDuration(text: status.callInfo.video ? CallStrings.incomeVideoCalling.localized : CallStrings.incomeAudioCalling.localized)
        case .outcoming:
            infoView.setDuration(text: CallStrings.connecting.localized)
        }
        setSpeaker(status.callInfo.video)
    }
    
    private func remakeInfoViewConstraints(isVideo: Bool) {
        infoView.configureToVideoCall(isVideo: isVideo)
        infoView.snp.remakeConstraints { make in
            if isVideo {
                guard let navigationController else { return }
                make.centerY.equalTo(navigationController.navigationBar.snp.centerY)
            } else {
                make.bottom.equalTo(view.snp.centerY).offset(-36)
            }
            make.leading.trailing.equalToSuperview()
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        endTimer()
    }
}

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
        guard let callStatus = presenter?.getCallStatus() else { return }
        if callStatus.callInfo.video {
            actionStackView.setAsActiveCamera()
            setSpeaker(true)
            remakeInfoViewConstraints(isVideo: true)
        } else {
            actionStackView.setAsActiveAudio()
        }
        connectRoom(with: callStatus.callInfo)
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
        endTimer()
        infoView.setDuration(text: CallStrings.cancel.localized)
        presenter?.cancel()
    }
    
    func view(_ view: IncomingCallActionView, rejectButtonDidTap button: UIButton) {
        infoView.setDuration(text: CallStrings.reject.localized)
        presenter?.reject()
    }
    
    private func setSpeaker(_ isEnabled: Bool) {
        audioQueue.async {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: isEnabled ? [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP] : [.duckOthers, .allowBluetooth, .allowBluetoothA2DP])
            try? audioSession.setActive(true)
        }
    }
    
}

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
    
    private func dismissPage() {
        if let presentingViewController {
            presentingViewController.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func dispay(view contact: ContactDisplayable) {
        infoView.confige(view: contact)
    }
    
    private func configureStartCall() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            infoView.hidePhoneNumber()
            startTimer()
        }
    }
    
}

// MARK: - RoomDelegate

extension IncomingCallViewController: RoomDelegate {
    
    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {
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
        
    private func setVideoCallIfPossible(enabled: Bool) {
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
    
    private func deniedCameraPermission() {
        actionStackView.cameraButton.isSelected = false
        actionStackView.mouthpieceButton.isSelected = false
        actionStackView.setAsActiveAudio()
        remakeInfoViewConstraints(isVideo: false)
        setSpeaker(false)
    }
    
    private func setMicrophoneIfPossible(enabled: Bool) {
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
    
    private func startTimer() {
        guard displayLink == nil else { return }

        displayLink = CADisplayLink(target: self, selector: #selector(displayRefreshed))
        displayLink?.add(to: .main, forMode: .default)
        date = Date()
    }

    @objc
    private func displayRefreshed(displayLink: CADisplayLink) {
        guard let startDate = date, room.connectionState == .connected else { return }
        let elepsadeTime = Int(Date().timeIntervalSince(startDate).rounded(.toNearestOrEven))
        infoView.setDuration(text: timeFormatted(elepsadeTime))
    }

    func endTimer() {
        displayLink?.invalidate()
        displayLink = nil
        date = nil
    }
    
    private func timeFormatted(_ second: Int) -> String {
        let seconds: Int = second % 60
        let minutes: Int = (second / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}

//MARK: - Extensions

private extension ConnectionState {
    var desctiption: String {
        switch self {
        case .connected:
            return CallStrings.connected.localized
        case .disconnected:
            return CallStrings.disconnected.localized
        case .connecting:
            return CallStrings.connecting.localized
        case .reconnecting:
            return CallStrings.reconnecting.localized
        }
    }
}

extension UIView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
    
    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
}
