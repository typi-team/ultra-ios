//
//  RecordView.swift
//  UltraCore
//
//  Created by Slam on 10/24/23.
//
import UIKit

public class RecordView: UIView, CAAnimationDelegate {

    private var isSwiped = false
    private var bucketImageView: BucketImageView!

    private var timer: Timer?
    private var duration: CGFloat = 0
    private var mTransform: CGAffineTransform!
    private var audioPlayer: AudioPlayer!
    
    private var timerStackView: UIStackView!
    private var slideToCancelStackVIew: UIStackView!

    public weak var delegate: RecordViewDelegate?
    public var offset: CGFloat = 0
    public var isSoundEnabled = false
    public var buttonTransformScale: CGFloat = 2

    public var slideToCancelText: String! {
        didSet {
            slideLabel.text = slideToCancelText
        }
    }

    public var slideToCancelTextColor: UIColor! {
        didSet {
            slideLabel.textColor = slideToCancelTextColor
        }
    }

    public var slideToCancelArrowImage: UIImage! {
        didSet {
            arrow.image = slideToCancelArrowImage
        }
    }

    public var smallMicImage: UIImage! {
        didSet {
            bucketImageView.smallMicImage = smallMicImage
        }
    }

    public var durationTimerColor: UIColor! {
        didSet {
            timerLabel.textColor = durationTimerColor
        }
    }


    private let arrow: UIImageView = .init{
        $0.image = UIImage.named("voice.arrow")
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let slideLabel: RegularCallout =  .init {
        $0.text = "Slide To Cancel"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private var timerLabel: RegularCallout = .init{
        $0.text = "00:00"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setup() {
        bucketImageView = BucketImageView(frame: frame)
        bucketImageView.animationDelegate = self
        bucketImageView.translatesAutoresizingMaskIntoConstraints = false
        bucketImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        bucketImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true


        timerStackView = UIStackView(arrangedSubviews: [bucketImageView, timerLabel])
        timerStackView.translatesAutoresizingMaskIntoConstraints = false
        timerStackView.isHidden = true
        timerStackView.spacing = 5


        slideToCancelStackVIew = UIStackView(arrangedSubviews: [arrow, slideLabel])
        slideToCancelStackVIew.translatesAutoresizingMaskIntoConstraints = false
        slideToCancelStackVIew.isHidden = true
        slideToCancelStackVIew.spacing = kMediumPadding


        addSubview(timerStackView)
        addSubview(slideToCancelStackVIew)


        arrow.widthAnchor.constraint(equalToConstant: 15).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 15).isActive = true

        slideToCancelStackVIew.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        slideToCancelStackVIew.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true


        timerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        timerStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true


        mTransform = CGAffineTransform(scaleX: buttonTransformScale, y: buttonTransformScale)

        audioPlayer = AudioPlayer()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }


    func onTouchDown(recordButton: RecordButton) {
        onStart(recordButton: recordButton)
    }

    func onTouchUp(recordButton: RecordButton) {
        guard !isSwiped else {
            return
        }
        onFinish(recordButton: recordButton)
    }
    
    func onTouchCancelled(recordButton: RecordButton) {
        onTouchCancel(recordButton: recordButton)
    }


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    @objc private func updateDuration() {
        duration += 1
        timerLabel.text = duration.fromatSecondsFromTimer()
    }

    //this will be called when user starts tapping the button
    private func onStart(recordButton: RecordButton) {
        isSwiped = false

        self.prepareToStartRecording(recordButton: recordButton)

        if isSoundEnabled {
            audioPlayer.playAudioFile(soundType: .start)
            audioPlayer.didFinishPlaying = { [weak self] _ in
                self?.delegate?.onStart()
            }
        } else {
            delegate?.onStart()
        }
    }
    
    private func prepareToStartRecording(recordButton: RecordButton) {
        resetTimer()

        //start timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)


        //reset all views to default
        slideToCancelStackVIew.transform = .identity
        recordButton.transform = .identity

        //animate button to scale up
        UIView.animate(withDuration: 0.2) {
            recordButton.transform = self.mTransform
        }


        slideToCancelStackVIew.isHidden = false
        timerStackView.isHidden = false
        timerLabel.isHidden = false
        bucketImageView.isHidden = false
        bucketImageView.resetAnimations()
        bucketImageView.animateAlpha()
    }

    fileprivate func animateRecordButtonToIdentity(_ recordButton: RecordButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            recordButton.transform = .identity
        })
    }
    
    //this will be called when user swipes to the left and cancel the record
    fileprivate func hideCancelStackViewAndTimeLabel() {
        slideToCancelStackVIew.isHidden = true
        timerLabel.isHidden = true
    }
    
    private func onSwipe(recordButton: RecordButton) {
        isSwiped = true
        audioPlayer.didFinishPlaying = nil
        
        animateRecordButtonToIdentity(recordButton)

        hideCancelStackViewAndTimeLabel()

        if !isLessThanOneSecond() {
            bucketImageView.animateBucketAndMic()

        } else {
            bucketImageView.isHidden = true
            delegate?.onAnimationEnd?()
        }

        resetTimer()

        delegate?.onCancel()
    }
    
    private func onTouchCancel(recordButton: RecordButton) {
        isSwiped = false
        
        audioPlayer.didFinishPlaying = nil
        
        animateRecordButtonToIdentity(recordButton)
        
        hideCancelStackViewAndTimeLabel()
        
        bucketImageView.isHidden = true
        delegate?.onAnimationEnd?()
        
        resetTimer()
        
        delegate?.onCancel()
    }

    private func resetTimer() {
        timer?.invalidate()
        timerLabel.text = "00:00"
        duration = 0
        timer = nil
    }

    //this will be called when user lift his finger
    private func onFinish(recordButton: RecordButton) {
        isSwiped = false
        audioPlayer.didFinishPlaying = nil
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            recordButton.transform = .identity
        })


        slideToCancelStackVIew.isHidden = true
        timerStackView.isHidden = true

        timerLabel.isHidden = true


        if isLessThanOneSecond() {
            if isSoundEnabled {
                audioPlayer.playAudioFile(soundType: .error)
            }
        } else {
            if isSoundEnabled {
                audioPlayer.playAudioFile(soundType: .end)
            }
        }

        delegate?.onFinished(duration: duration)

        resetTimer()

    }

    //this will be called when user starts to move his finger
    func touchMoved(recordButton: RecordButton, sender: UIPanGestureRecognizer) {

        guard !isSwiped else {
            return
        }

        let button = sender.view!
        let translation = sender.translation(in: button)

        switch sender.state {
        case .changed:

            //prevent swiping the button outside the bounds
            if translation.x < 0 {
                //start move the views
                let transform = mTransform.translatedBy(x: translation.x, y: 0)
                button.transform = transform
                slideToCancelStackVIew.transform = transform.scaledBy(x: 0.5, y: 0.5)


                if slideToCancelStackVIew.frame.intersects(timerStackView.frame.offsetBy(dx: offset, dy: 0)) {
                    onSwipe(recordButton: recordButton)
                }

            }
        default:
            break
        }

    }

}


extension RecordView: AnimationFinishedDelegate {
    func animationFinished() {
        slideToCancelStackVIew.isHidden = true
        timerStackView.isHidden = false
        timerLabel.isHidden = true
        delegate?.onAnimationEnd?()
    }
}

private extension RecordView {
    func isLessThanOneSecond() -> Bool {
        return duration < 1
    }
}


extension CGFloat {
    func fromatSecondsFromTimer() -> String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
