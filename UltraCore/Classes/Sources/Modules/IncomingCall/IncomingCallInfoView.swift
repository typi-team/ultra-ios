import UIKit

final class IncomingCallInfoView: UIView {
    
    private let style: CallPageStyle
    
    // MARK: - Views
    
    fileprivate lazy var avatarView: UIImageView = .init {
        $0.borderWidth = 0
        $0.cornerRadius = 40
        $0.backgroundColor = .white
    }

    fileprivate lazy var companionLabel: HeadlineBody = .init {
        $0.textAlignment = .center
        $0.font = style.companionConfig.font
        $0.textColor = style.companionConfig.color
    }

    fileprivate lazy var dutationLabel: RegularBody = .init {
        $0.textAlignment = .center
        $0.font = style.durationConfig.font
        $0.textColor = style.durationConfig.color
    }
    
    fileprivate lazy var phoneLabel: RegularBody = .init {
        $0.textAlignment = .center
        $0.font = style.durationConfig.font
        $0.textColor = style.durationConfig.color
    }
    
    fileprivate lazy var stackView: UIStackView = .init {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    // MARK: - Init
    
    init(style: CallPageStyle) {
        self.style = style
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func confige(view contact: ContactDisplayable) {
        avatarView.set(contact: contact, placeholder: UltraCoreStyle.defaultPlaceholder?.image)
        companionLabel.text = contact.displaName
        phoneLabel.text = contact.phone
    }
    
    func setDuration(text: String) {
        dutationLabel.text = text
    }
    
    func hidePhoneNumber() {
        phoneLabel.removeFromSuperview()
    }
    
    func configureToVideoCall(isVideo: Bool) {
        avatarView.isHidden = isVideo
        phoneLabel.isHidden = isVideo
        stackView.spacing = isVideo ? 4 : 8
        companionLabel.font = isVideo ? style.companionVideoConfig.font : style.companionConfig.font
        dutationLabel.font = isVideo ? style.durationVideoConfig.font : style.durationConfig.font
    }
    
    private func setup() {
        setupViews()
        makeConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        addSubview(stackView)
        [avatarView, companionLabel, dutationLabel, phoneLabel].forEach { stackView.addArrangedSubview($0) }
    }
    
    private func makeConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kLowPadding)
            make.right.equalToSuperview().offset(-kLowPadding)
            make.bottom.equalToSuperview()
        }
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        companionLabel.textColor = style.companionConfig.color
        dutationLabel.textColor = style.durationConfig.color
        phoneLabel.textColor = style.durationConfig.color
    }
    
}
