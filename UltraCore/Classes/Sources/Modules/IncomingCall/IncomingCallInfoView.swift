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
        phoneLabel.isHidden = true
    }
    
    private func setup() {
        setupViews()
        makeConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        addSubview(avatarView)
        addSubview(companionLabel)
        addSubview(dutationLabel)
        addSubview(phoneLabel)
    }
    
    private func makeConstraints() {
        avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(companionLabel.snp.top).offset(-kLowPadding)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        companionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(dutationLabel.snp.top).offset(-kLowPadding)
            make.left.equalToSuperview().offset(kLowPadding)
            make.right.equalToSuperview().offset(-kLowPadding)
        }
        dutationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(phoneLabel.snp.top).offset(-kLowPadding)
            make.left.equalToSuperview().offset(kLowPadding)
            make.right.equalToSuperview().offset(-kLowPadding)
        }
        phoneLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}
