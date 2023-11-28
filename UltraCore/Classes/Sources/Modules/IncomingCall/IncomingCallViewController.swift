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

final class IncomingCallViewController: BaseViewController<IncomingCallPresenterInterface> {
    
    fileprivate lazy var room = Room(delegate: self)
    fileprivate lazy var timer: Timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] timer in
        self?.infoView.setDuration(text: timer.tolerance.description)
    })

    fileprivate lazy var localVideoView: VideoView = .init({
        $0.cornerRadius = kLowPadding
    })

    fileprivate lazy var remoteVideoView: VideoView = .init({
        $0.cornerRadius = kLowPadding
    })

    fileprivate lazy var style: CallPageStyle = UltraCoreStyle.callingConfig

    fileprivate lazy var infoView = IncomingCallInfoView(style: style)

    fileprivate lazy var actionStackView = IncomingCallActionView(style: style, delegate: self)

    override func setupViews() {
        super.setupViews()

        self.view.backgroundColor = self.style.background.color

        self.view.addSubview(localVideoView)
        self.view.addSubview(remoteVideoView)
        self.view.addSubview(infoView)
        self.view.addSubview(actionStackView)
    }

    override func setupConstraints() {
        super.setupConstraints()

        self.actionStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-54)
            make.left.equalToSuperview().offset(kHeadlinePadding)
            make.right.equalToSuperview().offset(-kHeadlinePadding)
            make.height.equalTo(52)
        }
        self.infoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY).offset(-36)
        }
        self.localVideoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.remoteVideoView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(31)
            make.bottom.equalTo(actionStackView.snp.top).offset(-32)
            make.width.equalTo(90)
            make.height.equalTo(150)
        }
    }

    override func setupInitialData() {
        super.setupInitialData()

        guard let status = self.presenter?.viewDidLoad() else { return }
        actionStackView.configure(status: status)
        switch status {
        case let .incoming(request), let .outcoming(request):
            room.localParticipant?.setCamera(enabled: request.video)
        }
    }

    deinit {
        _ = self.room.disconnect()
    }
}

// MARK: - Extensions -

extension IncomingCallViewController: IncomingCallActionViewDelegate {
    
    func view(_ view: IncomingCallActionView, answerButtonDidTap button: UIButton) {
        guard let callInfo = presenter?.viewDidLoad() else { return }
        connect(with: callInfo.callInfo)
    }
    
    func view(_ view: IncomingCallActionView, mouthpieceButtonDidTap button: UIButton) {
//        _ = room.localParticipant?.isSpeaking = !button.isSelected
    }
    
    func view(_ view: IncomingCallActionView, microButtonDidTap button: UIButton) {
        _ = room.localParticipant?.set(source: .microphone, enabled: !button.isSelected)
    }
    
    func view(_ view: IncomingCallActionView, cameraButtonDidTap button: UIButton) {
        _ = room.localParticipant?.set(source: .camera, enabled: !button.isSelected)
    }
    
    func view(_ view: IncomingCallActionView, cancelButtonDidTap button: UIButton) {
        infoView.setDuration(text: "Close connection")
        presenter?.cancel()
    }
    
    func view(_ view: IncomingCallActionView, rejectButtonDidTap button: UIButton) {
        infoView.setDuration(text: "Reject connection")
        presenter?.reject()
    }
    
}

extension IncomingCallViewController: IncomingCallViewInterface {
    func disconnectRoom() {
        self.room.disconnect().then({[weak self] () in
            self?.navigationController?.popViewController(animated: true)
        }).catch { [weak self] error  in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    func dispay(view contact: ContactDisplayable) {
        infoView.confige(view: contact)
    }
}

extension IncomingCallViewController: RoomDelegateObjC {
    func room(_ room: Room, didUpdate connectionState: ConnectionStateObjC, oldValue oldConnectionState: ConnectionStateObjC) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.infoView.setDuration(text: connectionState.desctiption)
            self.infoView.hidePhoneNumber()
            switch connectionState {
            case .disconnected, .connecting, .reconnecting:
                self.timer.invalidate()
            case .connected:
                self.timer.fire()
            }
        }
    }

    func room(_ room: Room, didUpdate metadata: String?) {
        PP.debug(metadata ?? "as")
    }

    func room(_ room: Room, localParticipant: LocalParticipant, didPublish publication: LocalTrackPublication) {
        guard let track = publication.track as? VideoTrack else {
              return
          }
          DispatchQueue.main.async {
              self.localVideoView.track = track
          }
      }

      func room(_ room: Room, participant: RemoteParticipant, didSubscribe publication: RemoteTrackPublication, track: Track) {
          guard let track = track as? VideoTrack else {
            return
          }
          DispatchQueue.main.async {
              self.remoteVideoView.track = track
          }
      }
}

private extension IncomingCallViewController {
    func connect(with callInfo: CallInformation) {
        self.room.connect(callInfo.host, callInfo.accessToken).then { [weak self] room in
            guard let self, let status = self.presenter?.viewDidLoad() else { return }
            self.actionStackView.configure(status: status)
            room.localParticipant?.setCamera(enabled: callInfo.video)
            room.localParticipant?.setMicrophone(enabled: true)
        }.catch { error in
            self.dismiss(animated: true)
        }
    }
}

private extension ConnectionStateObjC {
    var desctiption: String {
        switch self {
        case .connected:return CallStrings.connected.localized
        case .disconnected:
            return CallStrings.disconnected.localized
        case .connecting:
            return CallStrings.connecting.localized
        case .reconnecting:
            return CallStrings.reconnecting.localized
        }
    }
}
