import RxSwift
import AVFoundation

class MakeSoundInteractor: UseCase<MakeSoundInteractor.Sound, Void> {
    
    private var player: AVAudioPlayer?
    
    fileprivate let voiceRepository = AppSettingsImpl.shared.voiceRepository
    
    override func executeSingle(params: Sound) -> Single<Void> {
        Single<Void>.create { [weak self ] observer -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            self.make(sound: params)
            observer(.success(()))
            return Disposables.create()
        }
    }
    
    private func make(sound: Sound) {
        guard !voiceRepository.isPlaying else { return }
        
        let bundle = Bundle(for: AppSettingsImpl.self)
        if let resourceURL = bundle.url(forResource: "UltraCore", withExtension: "bundle"),
           let resourceBundle = Bundle(url: resourceURL),
           let soundURL = resourceBundle.url(forResource: sound.rawValue, withExtension: "wav")
        {
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                if player == nil {
                    player = try AVAudioPlayer(contentsOf: soundURL, fileTypeHint: AVFileType.wav.rawValue)
                }
                player?.prepareToPlay()
                player?.play()
            } catch {
                PP.debug(error.localizedDescription)
            }
        }
    }
   
}

extension MakeSoundInteractor {
    enum Sound: String {
        case messageSent = "outgoing"
    }
}
