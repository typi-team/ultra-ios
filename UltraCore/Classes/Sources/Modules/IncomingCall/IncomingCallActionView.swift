import Foundation

protocol IncomingCallActionViewDelegate: AnyObject {
    func view(_ view: IncomingCallActionView, answerButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, mouthpieceButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, microButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, cameraButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, cancelButtonDidTap button: UIButton)
    func view(_ view: IncomingCallActionView, rejectButtonDidTap button: UIButton)
}

final class IncomingCallActionView: UIStackView {
    
    private let style: CallPageStyle
    
    private weak var delegate: IncomingCallActionViewDelegate?
    
    // MARK: - Views
    
    fileprivate lazy var answerButton: UIButton = .init {
        $0.setImage(self.style.answerImage, for: .normal)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.delegate?.view(self, answerButtonDidTap: self.answerButton)
        }
    }
    
    fileprivate lazy var mouthpieceButton: UIButton = .init {
        $0.setImage(style.mouthpieceOffImage, for: .normal)
        $0.setImage(style.mouthpieceOnImage, for: .selected)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.mouthpieceButton.isSelected.toggle()
            self.delegate?.view(self, mouthpieceButtonDidTap: self.mouthpieceButton)
        }
    }

    fileprivate lazy var microButton: UIButton = .init {
        $0.setImage(style.micOnImage, for: .normal)
        $0.setImage(style.micOffImage, for: .selected)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.microButton.isSelected.toggle()
            self.delegate?.view(self, microButtonDidTap: self.microButton)
        }
    }

    fileprivate lazy var cameraButton: UIButton = .init {
        $0.setImage(style.cameraOffImage, for: .normal)
        $0.setImage(style.cameraOnImage, for: .selected)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.cameraButton.isSelected.toggle()
            self.delegate?.view(self, cameraButtonDidTap: self.cameraButton)
        }
    }

    fileprivate lazy var cancelButton: UIButton = .init {
        $0.setImage(style.declineImage, for: .normal)
        $0.addAction { [weak self] in
            guard let self else { return }
            self.delegate?.view(self, cancelButtonDidTap: self.cancelButton)
        }
    }

    fileprivate lazy var rejectButton: UIButton = .init {
        $0.setImage(style.declineImage, for: .normal)
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
        switch status {
        case .incoming:
            addArrangedSubview(answerButton)
            addArrangedSubview(rejectButton)
        case .outcoming:
            addArrangedSubview(mouthpieceButton)
            addArrangedSubview(microButton)
            addArrangedSubview(cameraButton)
            addArrangedSubview(cancelButton)
        }
    }
    
    private func setup() {
        axis = .horizontal
        spacing = kMediumPadding
        distribution = .equalCentering
    }
}
