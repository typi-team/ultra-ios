//
//  VoiceRepository.swift
//  UltraCore
//
//  Created by Slam on 8/10/23.
//

import Foundation
import AVFAudio
import RxSwift

class VoiceItem: CustomStringConvertible {
    let voiceMessage: VoiceMessage
    var currentTime: TimeInterval = 0.0
    var isPlaying: Bool

    init(voiceMessage: VoiceMessage, currentTime: TimeInterval, isPlaying: Bool) {
        self.voiceMessage = voiceMessage
        self.currentTime = currentTime
        self.isPlaying = isPlaying
    }

    var description: String {
        return "[VoiceItem]: \(voiceMessage.fileID) \(currentTime) / \(voiceMessage.duration) isPlaying: \(isPlaying)"
    }
}

class VoiceRepository: NSObject {
    
    fileprivate var timer: Timer?
    fileprivate let mediaUtils: MediaUtils
    fileprivate var audioPlayer: AVAudioPlayer?

    init(mediaUtils: MediaUtils) {
        self.mediaUtils = mediaUtils
    }
    
    var currentVoice: BehaviorSubject<VoiceItem?> = .init(value: nil)

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func stop(shouldReset: Bool = true) {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.timer?.invalidate()
        try? AVAudioSession.sharedInstance().setActive(false)
        if shouldReset {
            self.currentVoice.on(.next(nil))
        }
    }

    func playPause() {
        if audioPlayer?.isPlaying ?? false {
            self.audioPlayer?.pause()
            self.timer?.invalidate()
        } else {
            self.audioPlayer?.play()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            runTimerOnRunLoop()
        }
        let currentItem = try? currentVoice.value()
        currentItem?.isPlaying = audioPlayer?.isPlaying ?? false
        self.currentVoice.on(
            .next(currentItem)
        )
    }

    func play(message: Message, atTime: TimeInterval = .zero, isNeedPause: Bool = false) {
        guard let soundURL = self.mediaUtils.mediaURL(from: message) else { return }
        do {
            let shouldReset = atTime == .zero
            self.stop(shouldReset: shouldReset)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.currentTime = atTime
            audioPlayer.play()
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            runTimerOnRunLoop()
            self.audioPlayer = audioPlayer
            if isNeedPause {
                self.audioPlayer?.pause()
                self.timer?.invalidate()
            }
            self.currentVoice.on(
                .next(.init(voiceMessage: message.voice, currentTime: atTime, isPlaying: audioPlayer.isPlaying))
            )
        } catch {
            self.stop()
            PP.error(error.localizedDescription)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func mediaURL(message: Message) -> URL? {
        mediaUtils.mediaURL(from: message)
    }
    
    private func runTimerOnRunLoop() {
        guard let timer else { return }
        
        RunLoop.main.add(timer, forMode: .common)
    }
}

extension VoiceRepository: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stop()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        PP.error(error?.localizedDescription ?? "")
        self.stop()
    }
    
}

private extension VoiceRepository {
    @objc func updateTime() {
        guard let currentTime = self.audioPlayer?.currentTime else { return }
        if let currentVoice = try? self.currentVoice.value() {
            let newValue = currentVoice
            newValue.currentTime = currentTime
            self.currentVoice.onNext(newValue)
        }
    }

}
