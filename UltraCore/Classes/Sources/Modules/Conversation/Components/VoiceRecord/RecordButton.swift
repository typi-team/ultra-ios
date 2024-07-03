//
//  RecordButton.swift
//  UltraCore
//
//  Created by Slam on 10/24/23.
//
import UIKit
protocol RecordButtonDelegate: AnyObject {
    func end()
    func started()
    
}

open class RecordButton: UIButton, UIGestureRecognizerDelegate {

    public var recordView: RecordView!

    private let defaultImage = UltraCoreStyle.voiceInputBarConfig?.recordButtonDefaultImage.image
    private let recordingImage = UltraCoreStyle.voiceInputBarConfig?.recordButtonRecordingImage.image

    private var mTransform: CGAffineTransform?
    private var buttonCenter, slideCenter: CGPoint?

    private var touchDownAndUpGesture: iGesutreRecognizer!
    private var moveGesture: UIPanGestureRecognizer!

    public var listenForRecord: Bool! {
        didSet {
            touchDownAndUpGesture.isEnabled = listenForRecord
            moveGesture.isEnabled = listenForRecord
        }
    }

    // prevent color change (onClick) when adding the button using Storyboard
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                isHighlighted = false
            }
        }
    }

    private func setup() {
        self.clipsToBounds = false
        setTitle("", for: .normal)

        if image(for: .normal) == nil {
            setImage(defaultImage, for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
        }

        moveGesture = UIPanGestureRecognizer(target: self, action: #selector(touchMoved(_:)))
        moveGesture.delegate = self

        touchDownAndUpGesture = iGesutreRecognizer(target: self, action: #selector(handleUpAndDown(_:)))
        touchDownAndUpGesture.delegate = self

        addGestureRecognizer(moveGesture)
        addGestureRecognizer(touchDownAndUpGesture)

        if mTransform == nil {
            mTransform = transform
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    @objc private func touchDown() {
        recordView.onTouchDown(recordButton: self)
    }

    @objc private func touchDownOutside() {
        recordView.onTouchDown(recordButton: self)
    }

    @objc private func touchUp() {
        recordView.onTouchUp(recordButton: self)
    }

    @objc private func touchMoved(_ sender: UIPanGestureRecognizer) {
        recordView.touchMoved(recordButton: self, sender: sender)
    }

    @objc private func handleUpAndDown(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            recordView.onTouchDown(recordButton: self)
            setImage(recordingImage, for: .normal)
        case .ended:
            recordView.onTouchUp(recordButton: self)
            setImage(defaultImage, for: .normal)
        case .cancelled:
            recordView.onTouchCancelled(recordButton: self)
            setImage(defaultImage, for: .normal)
        default:
            break
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer == touchDownAndUpGesture && otherGestureRecognizer == moveGesture) || (gestureRecognizer == moveGesture && otherGestureRecognizer == touchDownAndUpGesture)
    }


}

extension RecordButton {
    open override func layoutSubviews() {
        super.layoutSubviews()
        superview?.bringSubviewToFront(self)
    }
}
