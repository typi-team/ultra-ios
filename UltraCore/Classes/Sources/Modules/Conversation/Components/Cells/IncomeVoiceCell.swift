//
//  IncomeVoiceCell.swift
//  UltraCore
//
//  Created by Slam on 8/10/23.
//

import Foundation
import NVActivityIndicatorView
import RxCocoa
import RxSwift
import SDWebImage


class IncomeVoiceCell: MediaCell {
    
    fileprivate let playImage: UIImage? = .named("conversation_play_sound_icon")
    fileprivate let pauseImage: UIImage? = .named("conversation_pause_sound_icon")
    fileprivate let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(
            frame: CGRect(origin: .zero, size: .init(width: 30, height: 30)),
            type: .circleStrokeSpin,
            color: .black,
            padding: 0
        )
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    fileprivate let voiceRepository = AppSettingsImpl.shared.voiceRepository

    fileprivate var isInSeekMessage: Message?
    
    fileprivate lazy var slider: UISlider = .init({
        $0.addTarget(self, action: #selector(self.seekTo(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit])
        $0.addTarget(self, action: #selector(self.beginSeek(_:)), for: .touchDown)
        $0.setThumbImage(.named("conversation.thumbImage"), for: .normal)
        
    })
    fileprivate let durationLabel: RegularFootnote = .init({ $0.text = "10.00₸" })
    
    fileprivate lazy var controllerView: UIButton = .init({
        $0.setImage(playImage, for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self, let message = self.message else { return }
            let fileID = try? self.voiceRepository.currentVoice.value()?.voiceMessage.fileID
            if  message.voice.fileID == fileID {
                self.voiceRepository.playPause()
                self.controllerView.setImage(self.playImage, for: .normal)
            } else {
                self.controllerView.setImage(self.pauseImage, for: .normal)
                self.voiceRepository.play(message: message)
            }
            
        }
    })
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(controllerView)
        self.container.addSubview(durationLabel)
        self.container.addSubview(slider)
        self.container.addSubview(spinner)
    }

    override func setupConstraints() {
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.width.equalTo(UIScreen.main.bounds.width - 120)
        }
        
        self.controllerView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(kLowPadding)
        }
        
        self.slider.snp.makeConstraints { make in
            make.left.equalTo(controllerView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.top.equalToSuperview().offset(kLowPadding)
            make.height.equalTo(kHeadlinePadding)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(kLowPadding)
            make.right.equalToSuperview().offset(-kLowPadding)
            
        }
        self.durationLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(kLowPadding)
            make.leading.equalTo(slider.snp.leading)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }
        self.spinner.snp.makeConstraints { make in
            make.center.equalTo(controllerView)
            make.size.equalTo(30)
        }
    }
    
    override func additioanSetup() {
        super.additioanSetup()
        self.voiceRepository
            .currentVoice
            .subscribe(onNext: { [weak self] voice in
                guard let `self` = self else { return }
                self.setupVoiceMessageIntoView(voice: voice)
            })
            .disposed(by: disposeBag)
    }

    override func setup(message: Message) {
        super.setup(message: message)
        self.durationLabel.text = message.voice.duration.timeInterval.formatSeconds
        bindLoader()
        if let currentVoice = try? voiceRepository.currentVoice.value(),
           self.message?.voice.fileID == currentVoice.voiceMessage.fileID,
           currentVoice.isPlaying {
            self.setupView(currentVoice, slider: false)
        }
    }

    private func bindLoader() {
        let driver = self.mediaRepository
            .downloadingImages
            .asObservable()
            .map { [weak self] fileDownloadRequest in
                fileDownloadRequest.first(where: { $0.fileID == self?.message?.fileID })
            }
            .map({ request -> Bool in
                guard let request = request else {
                    return false
                }
                let isLoading = request.fromChunkNumber < request.toChunkNumber
                return isLoading
            })
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: false)
        driver
            .drive(onNext: { [weak self] isLoading in
                self?.spinner.isHidden = !isLoading
                isLoading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            })
            .disposed(by: disposeBag)
        driver
            .drive(controllerView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    @objc private func seekTo(_ sender: UISlider) {
        guard let message = self.message else { return }
        self.isInSeekMessage = nil
        let value = TimeInterval(sender.value) * message.voice.duration.timeInterval;
        self.voiceRepository.play(message: message, atTime: value)

    }
    
    @objc private func beginSeek(_ sender: UISlider) {
        guard let message = self.message else { return }
        self.isInSeekMessage = message
    }
    
    deinit {
        self.voiceRepository.stop()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isInSeekMessage = nil
        self.slider.setValue(0.0, animated: true)
        self.durationLabel.text = 0.0.description
        self.controllerView.isHidden = false
        self.controllerView.setImage(self.playImage, for: .normal)
        self.spinner.isHidden = true
    }
    
    fileprivate func setupView(_ voice: VoiceItem, slider animated: Bool = true) {
        let duration = voice.voiceMessage.duration.timeInterval
        let value = (voice.currentTime / duration)
        let remainder = (duration - voice.currentTime)
        PP.warning(remainder.description)
        self.durationLabel.text = remainder < 0.3 ? duration.formatSeconds : remainder.formatSeconds
        self.slider.setValue(Float(value), animated: animated)
        self.controllerView.setImage(!voice.isPlaying ? self.playImage : self.pauseImage, for: .normal)
    }
    
    private func setupVoiceMessageIntoView(voice: VoiceItem?) {
       self.durationLabel.text = self.message?.voice.duration.timeInterval.formatSeconds
       if let voice = voice,
          self.message?.voice.fileID == voice.voiceMessage.fileID,
          self.isInSeekMessage?.voice.fileID != voice.voiceMessage.fileID {
           self.setupView(voice)
       } else if voice?.voiceMessage.fileID == self.message?.voice.fileID {
           //                IGNORE THIS CASE
       } else if self.isInSeekMessage != nil {
           //                IGNORE THIS CASE
       } else {
           self.slider.setValue(0.0, animated: true)
           self.controllerView.setImage(self.playImage, for: .normal)
       }
   }
}

class OutcomeVoiceCell: IncomeVoiceCell {
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_loading"))
    
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(statusView)
    }
    
    override func setupConstraints() {
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.width.equalTo(UIScreen.main.bounds.width - 120)
        }
        
        self.controllerView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(kLowPadding)
        }
        
        self.slider.snp.makeConstraints { make in
            make.left.equalTo(controllerView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.top.equalToSuperview().offset(kLowPadding)
            make.height.equalTo(kHeadlinePadding)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(kLowPadding)
            make.right.equalToSuperview().offset(-kLowPadding)
        }
        
        self.durationLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(kLowPadding)
            make.leading.equalTo(slider.snp.leading)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }
        
        self.statusView.snp.makeConstraints { make in
            make.right.equalTo(deliveryDateLabel.snp.left).offset(-(kLowPadding / 2))
            make.centerY.equalTo(self.deliveryDateLabel.snp.centerY)
        }

        self.spinner.snp.makeConstraints { make in
            make.center.equalTo(controllerView)
            make.size.equalTo(30)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = message.statusImage
    }
}
