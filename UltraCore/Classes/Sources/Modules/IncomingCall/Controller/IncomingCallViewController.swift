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
    
    // MARK: - Properties
    
    lazy var room = Room(delegate: self)
    
    var displayLink: CADisplayLink?
    
    var date: Date?
    
    let audioQueue = DispatchQueue(label: "audio")
        
    lazy var style: CallPageStyle = UltraCoreStyle.callingConfig
    
    // MARK: - Views
    
    lazy var localVideoView: VideoView = .init({
        $0.isHidden = true
        $0.cornerRadius = kLowPadding
    })

    lazy var remoteVideoView: VideoView = .init({
        $0.isHidden = true
        $0.cornerRadius = kLowPadding
    })

    lazy var infoView = IncomingCallInfoView(style: style)

    lazy var actionStackView = IncomingCallActionView(style: style, delegate: self)
    
    fileprivate lazy var topView: UIView = .init {
        let gradient = CAGradientLayer()
        gradient.locations = [0, 1]
        gradient.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 100)
        gradient.colors = [style.background.color.withAlphaComponent(1).cgColor,
                           style.background.color.withAlphaComponent(0).cgColor]
        $0.layer.addSublayer(gradient)
        $0.isHidden = true
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = style.background.color
    }

    // MARK: - Setups
    
    override func setupViews() {
        super.setupViews()

        view.addSubview(remoteVideoView)
        view.addSubview(infoView)
        view.addSubview(actionStackView)
        view.addSubview(localVideoView)
        view.insertSubview(topView, aboveSubview: remoteVideoView)
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
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
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
    
    // MARK: - Methods
    
    func remakeInfoViewConstraints(isVideo: Bool) {
        infoView.configureToVideoCall(isVideo: isVideo)
        infoView.snp.remakeConstraints { make in
            if isVideo {
                guard let navigationController else { return }
                make.centerY.equalTo(navigationController.navigationBar.snp.centerY)
                topView.isHidden = false
            } else {
                make.bottom.equalTo(view.snp.centerY).offset(-36)
                topView.isHidden = true
            }
            make.leading.trailing.equalToSuperview()
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setSpeaker(_ isEnabled: Bool) {
        audioQueue.async {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: isEnabled ? [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP] : [.duckOthers, .allowBluetooth, .allowBluetoothA2DP])
            try? audioSession.setActive(true)
        }
    }
    
    func configureStartCall() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            infoView.hidePhoneNumber()
            startTimer()
        }
    }

    deinit {
        endTimer()
    }
}
