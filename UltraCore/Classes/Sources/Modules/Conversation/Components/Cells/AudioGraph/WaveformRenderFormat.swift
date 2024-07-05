import UIKit
import AVFoundation
import Accelerate

struct WaveformRenderFormat {
    internal var wavesColor: UIColor
    
    public var scale: CGFloat
    
    public let constrainImageSizeToExactlyMatch = false
    
    public init() {
        self.init(wavesColor: .black,
                  scale: UIScreen.main.scale)
    }
    
    init(wavesColor: UIColor, scale: CGFloat) {
        self.wavesColor = wavesColor
        self.scale = scale
    }
}

final public class WaveformRenderOperation: Operation {
    
    let audioContext: AudioContext
    
    public let imageSize: CGSize
    
    public let sampleRange: CountableRange<Int>
    
    let format: WaveformRenderFormat
    
    // MARK: - NSOperation Overrides
    
    public override var isAsynchronous: Bool { return true }
    
    private var _isExecuting = false
    public override var isExecuting: Bool { return _isExecuting }
    
    private var _isFinished = false
    public override var isFinished: Bool { return _isFinished }
    
    // MARK: - Private
    
    private let completionHandler: (UIImage?) -> ()
    
    private var renderedImage: UIImage?
    
    init(audioContext: AudioContext, imageSize: CGSize, sampleRange: CountableRange<Int>? = nil, format: WaveformRenderFormat = WaveformRenderFormat(), completionHandler: @escaping (_ image: UIImage?) -> ()) {
        self.audioContext = audioContext
        self.imageSize = imageSize
        self.sampleRange = sampleRange ?? 0..<audioContext.totalSamples
        self.format = format
        self.completionHandler = completionHandler
        
        super.init()
        
        self.completionBlock = { [weak self] in
            guard let `self` = self else { return }
            self.completionHandler(self.renderedImage)
            self.renderedImage = nil
        }
    }
    
    public override func start() {
        guard !isExecuting && !isFinished && !isCancelled else { return }
        
        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        didChangeValue(forKey: "isExecuting")
        
        if #available(iOS 8.0, *) {
            DispatchQueue.global(qos: .background).async { self.render() }
        } else {
            DispatchQueue.global(priority: .background).async { self.render() }
        }
    }
    
    private func finish(with image: UIImage?) {
        guard !isFinished && !isCancelled else { return }
        
        renderedImage = image
        
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")
        _isExecuting = false
        _isFinished = true
        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
    
    private func render() {
        guard
            !sampleRange.isEmpty,
            imageSize.width > 0, imageSize.height > 0
            else {
                finish(with: nil)
                return
        }
        
        let targetSamples = Int(imageSize.width * format.scale)
        
        let image: UIImage? = {
            guard
                let (samples, sampleMax) = sliceAsset(withRange: sampleRange, andDownsampleTo: targetSamples),
                let image = plotWaveformGraph(samples, maximumValue: sampleMax, zeroValue: 0)
                else { return nil }
            
            return image
        }()
        
        finish(with: image)
    }
    
    func sliceAsset(withRange slice: CountableRange<Int>, andDownsampleTo targetSamples: Int) -> (samples: [CGFloat], sampleMax: CGFloat)? {
        guard !isCancelled else { return nil }
        
        guard
            !slice.isEmpty,
            targetSamples > 0,
            let reader = try? AVAssetReader(asset: audioContext.asset)
            else { return nil }
        
        var channelCount = 1
        var sampleRate: CMTimeScale = 44100
        let formatDescriptions = audioContext.assetTrack.formatDescriptions as! [CMAudioFormatDescription]
        for item in formatDescriptions {
            guard let fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item) else { return nil }
            channelCount = Int(fmtDesc.pointee.mChannelsPerFrame)
            sampleRate = Int32(fmtDesc.pointee.mSampleRate)
        }
        
        reader.timeRange = CMTimeRange(start: CMTime(value: Int64(slice.lowerBound), timescale: sampleRate),
                                       duration: CMTime(value: Int64(slice.count), timescale: sampleRate))
        let outputSettingsDict: [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
        let readerOutput = AVAssetReaderTrackOutput(track: audioContext.assetTrack, outputSettings: outputSettingsDict)
        readerOutput.alwaysCopiesSampleData = false
        reader.add(readerOutput)
        
        var sampleMax: CGFloat = 0
        let samplesPerPixel = max(1, channelCount * slice.count / targetSamples)
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
        
        var outputSamples = [CGFloat]()
        var sampleBuffer = Data()
        
        reader.startReading()
        defer { reader.cancelReading() }
        
        while reader.status == .reading {
            guard !isCancelled else { return nil }
            
            guard let readSampleBuffer = readerOutput.copyNextSampleBuffer(),
                let readBuffer = CMSampleBufferGetDataBuffer(readSampleBuffer) else {
                    break
            }

            var readBufferLength = 0
            var readBufferPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(readBuffer, atOffset: 0, lengthAtOffsetOut: &readBufferLength, totalLengthOut: nil, dataPointerOut: &readBufferPointer)
            sampleBuffer.append(UnsafeBufferPointer(start: readBufferPointer, count: readBufferLength))
            CMSampleBufferInvalidate(readSampleBuffer)
            
            let totalSamples = sampleBuffer.count / MemoryLayout<Int16>.size
            let downSampledLength = totalSamples / samplesPerPixel
            let samplesToProcess = downSampledLength * samplesPerPixel
            
            guard samplesToProcess > 0 else { continue }
            
            processSamples(fromData: &sampleBuffer,
                           sampleMax: &sampleMax,
                           outputSamples: &outputSamples,
                           samplesToProcess: samplesToProcess,
                           downSampledLength: downSampledLength,
                           samplesPerPixel: samplesPerPixel,
                           filter: filter)
        }
        
        let samplesToProcess = sampleBuffer.count / MemoryLayout<Int16>.size
        if samplesToProcess > 0 {
            guard !isCancelled else { return nil }
            
            let downSampledLength = 1
            let samplesPerPixel = samplesToProcess
            let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
            
            processSamples(fromData: &sampleBuffer,
                           sampleMax: &sampleMax,
                           outputSamples: &outputSamples,
                           samplesToProcess: samplesToProcess,
                           downSampledLength: downSampledLength,
                           samplesPerPixel: samplesPerPixel,
                           filter: filter)
        }
        
        if reader.status == .completed || true{
            return (outputSamples, sampleMax)
        } else {
            print("WaveformRenderOperation failed to read audio: \(String(describing: reader.error))")
            return nil
        }
    }
    
    func processSamples(fromData sampleBuffer: inout Data, sampleMax: inout CGFloat, outputSamples: inout [CGFloat], samplesToProcess: Int, downSampledLength: Int, samplesPerPixel: Int, filter: [Float]) {
        sampleBuffer.withUnsafeBytes { bytes in
            guard let samples = bytes.bindMemory(to: Int16.self).baseAddress else {
                return
            }
            
            var processingBuffer = [Float](repeating: 0.0, count: samplesToProcess)
            
            let sampleCount = vDSP_Length(samplesToProcess)
            
            vDSP_vflt16(samples, 1, &processingBuffer, 1, sampleCount)
            
            vDSP_vabs(processingBuffer, 1, &processingBuffer, 1, sampleCount)
                        
            var downSampledData = [Float](repeating: 0.0, count: downSampledLength)
            vDSP_desamp(processingBuffer,
                        vDSP_Stride(samplesPerPixel),
                        filter, &downSampledData,
                        vDSP_Length(downSampledLength),
                        vDSP_Length(samplesPerPixel))
            
            let downSampledDataCG = downSampledData.map { (value: Float) -> CGFloat in
                let element = CGFloat(value)
                if element > sampleMax { sampleMax = element }
                return element
            }
            
            sampleBuffer.removeFirst(samplesToProcess * MemoryLayout<Int16>.size)
            
            outputSamples += downSampledDataCG
        }
    }
    
    func plotWaveformGraph(_ samples: [CGFloat], maximumValue max: CGFloat, zeroValue min: CGFloat) -> UIImage? {
        guard !isCancelled else { return nil }
        
        let imageSize = CGSize(width: CGFloat(samples.count) / format.scale,
                               height: self.imageSize.height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, format.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            NSLog("WaveformView failed to get graphics context")
            return nil
        }
        context.scaleBy(x: 1 / format.scale, y: 1 / format.scale) // Scale context to account for scaling applied to image
        context.setShouldAntialias(false)
        context.setAlpha(1.0)
        context.setLineWidth(30 / format.scale)
        context.setStrokeColor(format.wavesColor.cgColor)
        
        let sampleDrawingScale: CGFloat
        if max == min {
            sampleDrawingScale = 0
        } else {
            sampleDrawingScale = (imageSize.height * format.scale) / 2 / (max - min)
        }
        let verticalMiddle = (imageSize.height * format.scale) / 2
        var index = 0
        
        for (x, sample) in samples.enumerated() {
            let height = (sample - min) * sampleDrawingScale
            if x == 0 || index == 32 {
                
                context.move(to: CGPoint(x: CGFloat(x), y: verticalMiddle - height))
                context.addLine(to: CGPoint(x: CGFloat(x), y: verticalMiddle + height))
                context.strokePath()
                
                context.addArc(center: CGPoint(x: CGFloat(x), y: verticalMiddle - height),
                               radius: 0.05,
                               startAngle: CGFloat.pi,
                               endAngle: 0,
                               clockwise: false)
                context.strokePath()
                context.addArc(center: CGPoint(x: CGFloat(x), y: verticalMiddle + height),
                               radius: 0.05,
                               startAngle: 0,
                               endAngle: CGFloat.pi,
                               clockwise: false)
                context.strokePath()
                index = 1
            }
            index += 1
        }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            NSLog("WaveformView failed to get waveform image from context")
            return nil
        }
        
        return image
    }
}

extension AVAssetReader.Status : CustomStringConvertible{
    public var description: String{
        switch self{
        case .reading: return "reading"
        case .unknown: return "unknown"
        case .completed: return "completed"
        case .failed: return "failed"
        case .cancelled: return "cancelled"
        @unknown default:
            fatalError()
        }
    }
}
