//
//  AudioRecordUtils.swift
//  UltraCore
//
//  Created by Slam on 8/9/23.
//

import UIKit
import AVFoundation

protocol AudioRecordUtilsDelegate: AnyObject {
    func recordedVoice(url: URL, in duration: TimeInterval)
    func requestRecordPermissionIsFalse()
    func recordingVoice(average power: Float)
    func recodedDuration(time interal: TimeInterval)
}

class AudioRecordUtils: NSObject {
    
    weak var delegate: AudioRecordUtilsDelegate?
    
    private var timer: Timer?
    private var audioURL: URL?
    private var fireDate = Date()
    private var audioRecorder: AVAudioRecorder?

    func requestRecordPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard let `self` = self else { return }
            if granted {
                do {
                    try self.setupAudioRecorder()
                    self.startRecording()
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                self.delegate?.requestRecordPermissionIsFalse()
            }
        }
    }
    
    // MARK: - Audio Recording
    
    func setupAudioRecorder() throws {
        guard let audioFilename = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("voice_\(Date().nanosec).wav") else { return }
        self.audioURL = audioFilename
         

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        self.audioRecorder?.delegate = self
        self.audioRecorder?.isMeteringEnabled = true
        self.audioRecorder?.prepareToRecord()
    }
    
    func startRecording() {
        self.fireDate = Date()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] timer in
            guard let `self` = self else { return }
            self.delegate?.recodedDuration(time: Date().timeIntervalSince(self.fireDate))
            self.audioRecorder?.updateMeters()
            self.delegate?.recordingVoice(average: self.audioRecorder?.averagePower(forChannel: 0 ) ?? 0)
        })
        self.audioRecorder?.record()
        
    }
    
    func stopRecording() {
        self.timer?.invalidate()
        self.audioRecorder?.stop()
        
    }
    
    func cancelRecording() {
        self.timer?.invalidate()
        self.audioRecorder?.deleteRecording()
    }
    
    // MARK: - Audio Duration
    
    func audioDuration() -> TimeInterval? {
        guard let audioURL = audioURL, let audioFile = try? AVAudioFile(forReading: audioURL) else {
            return nil
        }
        return TimeInterval(audioFile.length) / audioFile.fileFormat.sampleRate
    }
}
// MARK: - AVAudioRecorderDelegate
extension AudioRecordUtils: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard let audioURL = self.audioURL else { return }
        if flag {
            self.delegate?.recordedVoice(url: audioURL, in: Date().timeIntervalSince(self.fireDate))
        } else {
            self.delegate?.requestRecordPermissionIsFalse()
        }
    }
}
