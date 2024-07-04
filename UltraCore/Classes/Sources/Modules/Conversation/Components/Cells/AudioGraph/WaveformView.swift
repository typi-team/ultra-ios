import UIKit
import MediaPlayer
import AVFoundation
import Accelerate

open class WaveformView: UIView {
    open weak var delegate: WaveformViewDelegate?

    private let mediaRepository: MediaRepository = AppSettingsImpl.shared.mediaRepository
    
    open var audioURL: URL? {
        didSet {
            guard let audioURL = audioURL else {
                NSLog("WaveformView received nil audioURL")
                audioContext = nil
                return
            }

            AudioContext.load(fromAudioURL: audioURL) { [weak self] audioContext in
                guard let self else { return }
                DispatchQueue.main.async {
                    guard self.audioURL == audioContext?.audioURL else { return }

                    if audioContext == nil {
                        NSLog("WaveformView failed to load URL: \(audioURL)")
                    }

                    self.audioContext = audioContext

                    self.loadingInProgress = false
                    self.delegate?.waveformViewDidLoad?(self)
                }
            } showLoading: {
                self.loadingInProgress = true
                self.delegate?.waveformViewWillLoad?(self)
            }
        }
    }
    
    private var pathFile: String? {
        if let path = audioURL?.lastPathComponent.split(separator: ".").first {
            return path + ".png"
        }
        return nil
    }
    
    private func updateGraphImageIfNeeded() {
        if let path = pathFile,
           let image = mediaRepository.audioGraphImage(from: path) {
            renderForCurrentAssetFailed = true
            waveformImage = image
            renderingInProgress = false
            cachedWaveformRenderOperation = nil
            setNeedsLayout()
        }
    }

    open var totalSamples: Int {
        return audioContext?.totalSamples ?? 0
    }

    open var highlightedSamples: CountableRange<Int>? = nil {
        didSet {
            guard totalSamples > 0 else {
                return
            }
            let highlightStartPortion = CGFloat(highlightedSamples?.startIndex ?? 0) / CGFloat(totalSamples)
            let highlightLastPortion = CGFloat(highlightedSamples?.last ?? 0) / CGFloat(totalSamples)
            let highlightWidthPortion = highlightLastPortion - highlightStartPortion
            self.clipping.frame = CGRect(x: self.frame.width * highlightStartPortion, y: 0, width: self.frame.width * highlightWidthPortion , height: self.frame.height)
            setNeedsLayout()
        }
    }

    open var zoomSamples: CountableRange<Int> = 0 ..< 0 {
        didSet {
            if zoomSamples.startIndex < 0{
                print("rip")
            }
            setNeedsDisplay()
            setNeedsLayout()
        }
    }

    /// Whether to allow tap and pan gestures to change highlighted range
    /// Pan gives priority to `doesAllowScroll` if this and that are both `true`
    open var doesAllowScrubbing = true

    /// The color of the waveform
    @IBInspectable open var wavesColor = UIColor.black {
        didSet {
            imageView.tintColor = wavesColor
        }
    }

    /// The color of the highlighted waveform (see `progressSamples`
    @IBInspectable open var progressColor = UIColor.blue {
        didSet {
            highlightedImage.tintColor = progressColor
        }
    }

    /// The portion of extra pixels to render left and right of the viewable region
    private var horizontalBleedTarget = 0.5

    /// The required portion of extra pixels to render left and right of the viewable region
    /// If this portion is not available then a re-render will be performed
    private var horizontalBleedAllowed = 0.1 ... 3.0

    /// The number of horizontal pixels to render per visible pixel on the screen (for anti-aliasing)
    private var horizontalOverdrawTarget = 3.0

    /// The required number of horizontal pixels to render per visible pixel on the screen (for anti-aliasing)
    /// If this number is not available then a re-render will be performed
    private var horizontalOverdrawAllowed = 1.5 ... 5.0

    /// The number of vertical pixels to render per visible pixel on the screen (for anti-aliasing)
    private var verticalOverdrawTarget = 2.0

    /// The required number of vertical pixels to render per visible pixel on the screen (for anti-aliasing)
    /// If this number is not available then a re-render will be performed
    private var verticalOverdrawAllowed = 1.0 ... 3.0

    /// The "zero" level (in dB)
    fileprivate let noiseFloor: CGFloat = -50.0
    
    /// Whether rendering for the current asset failed
    private var renderForCurrentAssetFailed = false

    /// Current audio context to be used for rendering
    private var audioContext: AudioContext? {
        didSet {
            waveformImage = nil
            zoomSamples = 0 ..< self.totalSamples
            highlightedSamples = nil
            inProgressWaveformRenderOperation = nil
            cachedWaveformRenderOperation = nil
            renderForCurrentAssetFailed = false

            setNeedsDisplay()
            setNeedsLayout()
        }
    }

    /// Currently running renderer
    private var inProgressWaveformRenderOperation: WaveformRenderOperation? {
        willSet {
            if newValue !== inProgressWaveformRenderOperation {
                inProgressWaveformRenderOperation?.cancel()
            }
        }
    }

    /// The render operation used to render the current waveform image
    private var cachedWaveformRenderOperation: WaveformRenderOperation?

    /// Image of waveform
    var waveformImage: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue?.withRenderingMode(.alwaysTemplate)
            highlightedImage.image = imageView.image
        }
    }

    /// Desired scale of image based on window's screen scale
    private var desiredImageScale: CGFloat {
        return window?.screen.scale ?? UIScreen.main.scale
    }

    /// Represents the status of the waveform renderings
    fileprivate enum CacheStatus {
        case dirty
        case notDirty(cancelInProgressRenderOperation: Bool)
    }

    fileprivate func decibel(_ amplitude: CGFloat) -> CGFloat {
        return 20.0 * log10(abs(amplitude))
    }

    /// View for rendered waveform
    lazy fileprivate var imageView: UIImageView = {
        let retval = UIImageView(frame: CGRect.zero)
        retval.contentMode = .scaleToFill
        retval.tintColor = self.wavesColor
        return retval
    }()

    /// View for rendered waveform showing progress
    lazy fileprivate var highlightedImage: UIImageView = {
        let retval = UIImageView(frame: CGRect.zero)
        retval.contentMode = .scaleToFill
        retval.tintColor = self.progressColor
        return retval
    }()

    /// A view which hides part of the highlighted image
    fileprivate let clipping: UIView = {
        let retval = UIView(frame: CGRect.zero)
        retval.clipsToBounds = true
        return retval
    }()

    enum PressType {
        case none
        case pinch
        case pan
    }

    /// Indicates the gesture begun lastly.
    /// This helps to determine which of the continuous interactions should be active, pinching or panning.
    /// pinchRecognizer
    fileprivate var firstGesture = PressType.none

    /// Gesture recognizer
    var panRecognizer = UIPanGestureRecognizer()

    /// Whether rendering is happening asynchronously
    fileprivate var renderingInProgress = false

    /// Whether loading is happening asynchronously
    open var loadingInProgress = false

    func setup() {
        addSubview(imageView)
        clipping.addSubview(highlightedImage)
        addSubview(clipping)
        clipsToBounds = true

        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }

    required public init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        setup()
    }

    override init(frame rect: CGRect) {
        super.init(frame: rect)
        setup()
    }

    deinit {
        inProgressWaveformRenderOperation?.cancel()
    }

    /// If the cached waveform or in-progress waveform is insufficient for the current frame
    fileprivate func cacheStatus() -> CacheStatus {
        guard !renderForCurrentAssetFailed else { return .notDirty(cancelInProgressRenderOperation: true) }

        let isInProgressRenderOperationDirty = isWaveformRenderOperationDirty(inProgressWaveformRenderOperation)
        let isCachedRenderOperationDirty = isWaveformRenderOperationDirty(cachedWaveformRenderOperation)

        if let isInProgressRenderOperationDirty = isInProgressRenderOperationDirty {
            if let isCachedRenderOperationDirty = isCachedRenderOperationDirty {
                if isInProgressRenderOperationDirty {
                    if isCachedRenderOperationDirty {
                        return .dirty
                    } else {
                        return .notDirty(cancelInProgressRenderOperation: true)
                    }
                } else if !isCachedRenderOperationDirty {
                    return .notDirty(cancelInProgressRenderOperation: true)
                }
            } else if isInProgressRenderOperationDirty {
                return .dirty
            }
        } else if let isLastWaveformRenderOperationDirty = isCachedRenderOperationDirty {
            if isLastWaveformRenderOperationDirty {
                return .dirty
            }
        } else {
            return .dirty
        }

        return .notDirty(cancelInProgressRenderOperation: false)
    }

    func isWaveformRenderOperationDirty(_ renderOperation: WaveformRenderOperation?) -> Bool? {
        guard let renderOperation = renderOperation else { return nil }

        if renderOperation.format.scale != desiredImageScale {
            return true
        }

        let requiredSamples = zoomSamples.extended(byFactor: horizontalBleedAllowed.lowerBound).clamped(to: 0 ..< totalSamples)
        if requiredSamples.clamped(to: renderOperation.sampleRange) != requiredSamples {
            return true
        }

        let allowedSamples = zoomSamples.extended(byFactor: horizontalBleedAllowed.upperBound).clamped(to: 0 ..< totalSamples)
        if renderOperation.sampleRange.clamped(to: allowedSamples) != renderOperation.sampleRange {
            return true
        }

        let verticalOverdrawRequested = Double(renderOperation.imageSize.height / frame.height)
        if !verticalOverdrawAllowed.contains(verticalOverdrawRequested) {
            return true
        }
        let horizontalOverdrawRequested = Double(renderOperation.imageSize.height / frame.height)
        if !horizontalOverdrawAllowed.contains(horizontalOverdrawRequested) {
            return true
        }

        return false
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        guard audioContext != nil && !zoomSamples.isEmpty else {
            return
        }

        switch cacheStatus() {
        case .dirty:
            renderWaveform()
            return
        case .notDirty(let cancelInProgressRenderOperation):
            if cancelInProgressRenderOperation {
                inProgressWaveformRenderOperation = nil
            }
        }

        // We need to place the images which have samples in `cachedSampleRange`
        // inside our frame which represents `startSamples..<endSamples`
        // all figures are a portion of our frame width

        var scaleX: CGFloat = 0.0
        var scaleW: CGFloat = 1.0
        var highlightScaleX: CGFloat = 0.0
        var highlightClipScaleL: CGFloat = 0.0
        var highlightClipScaleR: CGFloat = 1.0
        let cachedSampleRange = 0..<totalSamples
        scaleX = CGFloat(zoomSamples.lowerBound - cachedSampleRange.lowerBound) / CGFloat(cachedSampleRange.count)
        scaleW = CGFloat(cachedSampleRange.count) / CGFloat(zoomSamples.count)
        if let highlightedSamples = highlightedSamples {
            highlightScaleX = CGFloat(highlightedSamples.lowerBound - zoomSamples.lowerBound) / CGFloat(cachedSampleRange.count)
            highlightClipScaleL = max(0.0, CGFloat((highlightedSamples.lowerBound - cachedSampleRange.lowerBound) - (zoomSamples.lowerBound - cachedSampleRange.lowerBound)) / CGFloat(zoomSamples.count))
            highlightClipScaleR = min(1.0, 1.0 - CGFloat((zoomSamples.upperBound - highlightedSamples.upperBound)) / CGFloat(zoomSamples.count))
        }
        let childFrame = CGRect(x: frame.width * scaleW * -scaleX,
                                y: 0,
                                width: frame.width * scaleW,
                                height: frame.height)
        imageView.frame = childFrame
        if let highlightedSamples = highlightedSamples, highlightedSamples.overlaps(zoomSamples) {
            clipping.frame = CGRect(x: frame.width * highlightClipScaleL,
                                    y: 0,
                                    width: frame.width * (highlightClipScaleR - highlightClipScaleL),
                                    height: frame.height)
            if 0 < clipping.frame.minX {
                highlightedImage.frame = childFrame.offsetBy(dx: frame.width * scaleW * -highlightScaleX, dy: 0)
            } else {
                highlightedImage.frame = childFrame
            }
            clipping.isHidden = false
        } else {
            clipping.isHidden = true
        }
    }

    func renderWaveform() {
        guard let audioContext = audioContext else { return }
        if let path = pathFile,
           mediaRepository.audioGraphImage(from: path) != nil {
            updateGraphImageIfNeeded()
            return
        }
        
        guard !zoomSamples.isEmpty else { return }

        let renderSamples = zoomSamples.extended(byFactor: horizontalBleedTarget).clamped(to: 0 ..< totalSamples)
        let widthInPixels = floor(frame.width * CGFloat(horizontalOverdrawTarget))
        let heightInPixels = frame.height * CGFloat(horizontalOverdrawTarget)
        let imageSize = CGSize(width: widthInPixels, height: heightInPixels)
        let renderFormat = WaveformRenderFormat(wavesColor: .black, scale: desiredImageScale)

        let waveformRenderOperation = WaveformRenderOperation(audioContext: audioContext, imageSize: imageSize, sampleRange: renderSamples, format: renderFormat) { [weak self] image in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }

                if let image = image,
                   let fileID = audioContext.audioURL.lastPathComponent.split(separator: ".").first {
                    strongSelf.mediaRepository.createAudioGraphImage(from: String(fileID), image: image) {
                        strongSelf.delegate?.waveformViewDidRender?(strongSelf)
                    }
                }
                strongSelf.renderForCurrentAssetFailed = (image == nil)
                strongSelf.waveformImage = image
                strongSelf.renderingInProgress = false
                strongSelf.cachedWaveformRenderOperation = self?.inProgressWaveformRenderOperation
                strongSelf.inProgressWaveformRenderOperation = nil
                strongSelf.setNeedsLayout()
            }
        }
        self.inProgressWaveformRenderOperation = waveformRenderOperation

        renderingInProgress = true
        delegate?.waveformViewWillRender?(self)

        waveformRenderOperation.start()
    }
}

extension WaveformView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer {
            return false
        }
        return true
    }

    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard !zoomSamples.isEmpty, doesAllowScrubbing, delegate?.waveformScrubbingEnabled?(self) ?? false else { return }

        // This method is called even if the user began with pinching.

        switch recognizer.state {
        case .began:
            guard firstGesture != .pinch else { return }
            firstGesture = .pan
            delegate?.waveformDidBeginScrubbing?(self)
        case .ended, .cancelled:
            let isPan = firstGesture == .pan
            firstGesture = .none
            guard isPan else { return }
            delegate?.waveformDidEndScrubbing?(self)
        default:
            guard firstGesture == .pan, recognizer.numberOfTouches == 1 else { return }
        }
        
        let rangeSamples = CGFloat(zoomSamples.count)
        let scrubLocation = min(max(recognizer.location(in: self).x, 0), frame.width)    // clamp location within the frame
        highlightedSamples = 0 ..< Int((CGFloat(zoomSamples.startIndex) + rangeSamples * scrubLocation / bounds.width))
    }

}

/// To receive progress updates from WaveformView
@objc public protocol WaveformViewDelegate: NSObjectProtocol {
    /// Rendering will begin
    @objc optional func waveformViewWillRender(_ waveformView: WaveformView)

    /// Rendering did complete
    @objc optional func waveformViewDidRender(_ waveformView: WaveformView)

    /// An audio file will be loaded
    @objc optional func waveformViewWillLoad(_ waveformView: WaveformView)

    /// An audio file was loaded
    @objc optional func waveformViewDidLoad(_ waveformView: WaveformView)

    /// The panning gesture began
    @objc optional func waveformDidBeginScrubbing(_ waveformView: WaveformView)

    /// The scrubbing gesture ended
    @objc optional func waveformDidEndScrubbing(_ waveformView: WaveformView)
    
    @objc optional func waveformScrubbingEnabled(_ waveformView: WaveformView) -> Bool
}

extension CountableRange where Bound: Strideable {

    // Extend each bound away from midpoint by `factor`, a portion of the distance from begin to end
    func extended(byFactor factor: Double) -> CountableRange<Bound> {
        let theCount: Int = numericCast(count)
        let amountToMove: Bound.Stride = numericCast(Int(Double(theCount) * factor))
        return lowerBound.advanced(by: -amountToMove) ..< upperBound.advanced(by: amountToMove)
    }
}
