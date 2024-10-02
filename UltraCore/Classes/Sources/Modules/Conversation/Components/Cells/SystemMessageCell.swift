//
//  SystemMessageCell.swift
//  UltraCore
//
//  Created by Typi on 19.04.2024.
//

import UIKit

class SystemMessageCell: BaseCell {
    private lazy var cellAction = UITapGestureRecognizer(target: self, action: #selector(cellPress))
    private let label: AttributedLabel = {
        let label = AttributedLabel(frame: .zero)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    private var message: Message?

    var onCodeTap: ((String) -> Void)? {
        didSet {
            label.onCodeBlockTap = onCodeTap
        }
    }

    override func setupView() {
        super.setupView()
        contentView.addSubview(label)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectedBackgroundView = UIView({
            $0.backgroundColor = .clear
        })
        contentView.isUserInteractionEnabled = true
        label.hyperlinkAttributes = [
            .foregroundColor: UltraCoreStyle.systemMessageTextConfig.linkColor.color,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        label.font = UltraCoreStyle.systemMessageTextConfig.textLabelConfig.font
        label.textColor = UltraCoreStyle.systemMessageTextConfig.textLabelConfig.color
        cellAction.cancelsTouchesInView = false
        contentView.addGestureRecognizer(cellAction)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        } 
    }

    func setup(message: Message) {
        self.message = message
        label.attributedText = attributedText(for: message)
        label.onCodeBlockTap = onCodeTap
    }

    private func attributedText(for message: Message) -> NSAttributedString {
        let font = UltraCoreStyle.systemMessageTextConfig.textLabelConfig.font
        let textColor = UltraCoreStyle.systemMessageTextConfig.textLabelConfig.color
        guard !message.entities.isEmpty else {
            return NSAttributedString(
                string: message.supportMessage,
                attributes: attributes(
                    for: font,
                    textColor: textColor
                )
            )
        }

        let mutable = NSMutableAttributedString(string: message.supportMessage, attributes: attributes(for: font, textColor: textColor))

        for entity in message.entities {
            switch entity.entity {
            case .bold(let messageEntityBold):
                mutable.addAttributes(
                    [NSAttributedString.Key.font: UltraCoreStyle.systemMessageTextConfig.textBoldFont],
                    range: .init(location: Int(messageEntityBold.offset), length: Int(messageEntityBold.length))
                )
            case .italic(let messageEntityItalic):
                mutable.addAttributes(
                    [NSAttributedString.Key.font: UltraCoreStyle.systemMessageTextConfig.textItalicFont],
                    range: .init(location: Int(messageEntityItalic.offset), length: Int(messageEntityItalic.length))
                )
            case .pre:
                break
            case .url(let messageEntityUrl):
                let start = message.text.index(message.text.startIndex, offsetBy: Int(messageEntityUrl.offset))
                let end = message.text.index(message.text.startIndex, offsetBy: Int(messageEntityUrl.offset + messageEntityUrl.length))
                let substring = message.text[start..<end]
                guard let URL = URL(string: String(substring)) else {
                    break
                }

                mutable.addAttribute(
                    .link,
                    value: URL,
                    range: .init(location: Int(messageEntityUrl.offset), length: Int(messageEntityUrl.length))
                )
            case .textURL(let messageEntityTextUrl):
                guard let URL = URL(string: messageEntityTextUrl.url) else {
                    break
                }

                mutable.addAttribute(
                    .link,
                    value: URL,
                    range: .init(location: Int(messageEntityTextUrl.offset), length: Int(messageEntityTextUrl.length))
                )
            case .email:
                break
            case .phone:
                break
            case .underline(let messageEntityUnderline):
                mutable.addAttribute(
                    .underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: .init(location: Int(messageEntityUnderline.offset), length: Int(messageEntityUnderline.length))
                )
            case .strike(let messageEntityStrike):
                mutable.addAttribute(
                    .strikethroughStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: .init(location: Int(messageEntityStrike.offset), length: Int(messageEntityStrike.length))
                )
            case .quote:
                break
            case .mention:
                break
            case .code(let messageEntityCode):
                let backgroundColor = UltraCoreStyle.systemMessageTextConfig.codeSnippetBackgroundColor.color
                let codeColor = UltraCoreStyle.systemMessageTextConfig.codeSnippetConfig.color
                let font = UltraCoreStyle.systemMessageTextConfig.codeSnippetConfig.font
                let range = NSRange(location: Int(messageEntityCode.offset), length: Int(messageEntityCode.length))
                let text = (message.text as NSString).substring(with: range)
                mutable.addAttributes(
                    [
                        .backgroundColor: backgroundColor,
                        .font: font,
                        .foregroundColor: codeColor,
                        .codeBlock: text
                    ],
                    range: range
                )
            case .none:
                break
            }
        }

        return mutable
    }

    private func attributes(for font: UIFont?, textColor: UIColor?) -> [NSAttributedString.Key : Any] {
        var attributes = [NSAttributedString.Key: Any]()
        if let font = font {
            attributes[.font] = font
        }
        if let textColor = textColor {
            attributes[.foregroundColor] = textColor
        }
        return attributes
    }

    @objc private func cellPress() { }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard let message = message else {
            return
        }
        label.attributedText = attributedText(for: message)
    }
    
}
