import Foundation

protocol IncomingCallActionViewDelegate: AnyObject {
    func view(_ view: IncomingCallActionView, answerButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, mouthpieceButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, microButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, cameraButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, cancelButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, rejectButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, switchCameraButtonDidTap button: UIButton)
}

final class IncomingCallActionView: UIStackView {
    
    private let style: CallPageStyle
    
    private weak var delegate: IncomingCallActionViewDelegate?
    
    // MARK: - Views
    
    fileprivate lazy var answerButton: UIButton = .init {
        $0.setImage(self.style.answerImage.image, for: .normal)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.delegate?.view(self, answerButtonDidTap: self.answerButton)
        }
    }
    
    lazy var mouthpieceButton: UIButton = .init {
        $0.setImage(style.mouthpieceOffImage.image, for: .normal)
        $0.setImage(style.mouthpieceOnImage.image, for: .selected)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.mouthpieceButton.isSelected.toggle()
            self.delegate?.view(self, mouthpieceButtonDidTap: self.mouthpieceButton)
        }
    }

    lazy var microButton: UIButton = .init {
        $0.setImage(style.micOnImage.image, for: .selected)
        $0.setImage(style.micOffImage.image, for: .normal)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.microButton.isSelected.toggle()
            self.delegate?.view(self, microButtonDidTap: self.microButton)
        }
        $0.isSelected = true
    }
    
    fileprivate lazy var switchCameraButton: UIButton = .init {
        $0.setImage(style.switchFrontCameraImage.image, for: .normal)
        $0.setImage(style.switchBackCameraImage.image, for: .selected)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.switchCameraButton.isSelected.toggle()
            self.delegate?.view(self, switchCameraButtonDidTap: self.switchCameraButton)
        }
    }

    lazy var cameraButton: UIButton = .init {
        $0.setImage(style.cameraOffImage.image, for: .normal)
        $0.setImage(style.cameraOnImage.image, for: .selected)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.cameraButton.isSelected.toggle()
            self.delegate?.view(self, cameraButtonDidTap: self.cameraButton)
        }
    }

    fileprivate lazy var cancelButton: UIButton = .init {
        $0.setImage(style.declineImage.image, for: .normal)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.delegate?.view(self, cancelButtonDidTap: self.cancelButton)
        }
    }

    fileprivate lazy var rejectButton: UIButton = .init {
        $0.setImage(style.declineImage.image, for: .normal)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.delegate?.view(self, rejectButtonDidTap: self.rejectButton)
        }
    }

    // MARK: - Init
    
    init(style: CallPageStyle, delegate: IncomingCallActionViewDelegate?) {
        self.style = style
        self.delegate = delegate
        super.init(frame: .zero)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(status: CallStatus) {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        if status.callInfo.video {
            setAsActiveCamera()
        } else {
            setAsActiveAudio()
        }
    }

    func setAsActiveAudio() {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        addArrangedSubview(mouthpieceButton)
        addArrangedSubview(microButton)
        addArrangedSubview(cameraButton)
        addArrangedSubview(cancelButton)
        cameraButton.isSelected = false
    }
    
    func setAsActiveCamera() {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        addArrangedSubview(switchCameraButton)
        addArrangedSubview(microButton)
        addArrangedSubview(cameraButton)
        addArrangedSubview(cancelButton)
        cameraButton.isSelected = true
        mouthpieceButton.isSelected = true
    }

    private func setup() {
        axis = .horizontal
        spacing = kMediumPadding
        distribution = .equalCentering
    }
}
