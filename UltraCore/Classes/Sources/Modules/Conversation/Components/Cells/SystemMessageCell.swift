//
//  SystemMessageCell.swift
//  UltraCore
//
//  Created by Typi on 19.04.2024.
//

import UIKit

class SystemMessageCell: BaseCell {
    private let label: UILabel = .init {
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override func setupView() {
        super.setupView()
        contentView.addSubview(label)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectedBackgroundView = UIView({
            $0.backgroundColor = .clear
        })
        label.font = UltraCoreStyle.systemMessageTextConfig.font
        label.textColor = UltraCoreStyle.systemMessageTextConfig.color
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    func setup(message: Message) {
        label.attributedText = attributedText(for: message)
    }

    private func attributedText(for message: Message) -> NSAttributedString {
        let font = UltraCoreStyle.systemMessageTextConfig.font
        let textColor = UltraCoreStyle.systemMessageTextConfig.color
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
                let boldFont = message.isIncome ? UltraCoreStyle.incomeMessageCell?.textBoldFont : UltraCoreStyle.outcomeMessageCell?.textBoldFont
                mutable.addAttributes(
                    [NSAttributedString.Key.font: boldFont ?? .boldSystemFont(ofSize: 17)],
                    range: .init(location: Int(messageEntityBold.offset), length: Int(messageEntityBold.length))
                )
            case .italic(let messageEntityItalic):
                let italicFont = message.isIncome ? UltraCoreStyle.incomeMessageCell?.textItalicFont : UltraCoreStyle.outcomeMessageCell?.textItalicFont
                mutable.addAttributes(
                    [NSAttributedString.Key.font: italicFont ?? .italicSystemFont(ofSize: 17)],
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
                let backgroundColor = message.isIncome ?
                    UltraCoreStyle.incomeMessageCell?.codeSnippetBackgroundColor.color :
                    UltraCoreStyle.outcomeMessageCell?.codeSnippetBackgroundColor.color
                let codeColor = message.isIncome ?
                    UltraCoreStyle.incomeMessageCell?.codeSnippetConfig.color :
                    UltraCoreStyle.outcomeMessageCell?.codeSnippetConfig.color
                let font = message.isIncome ?
                    UltraCoreStyle.incomeMessageCell?.codeSnippetConfig.font : UltraCoreStyle.outcomeMessageCell?.codeSnippetConfig.font
                mutable.addAttributes(
                    [
                        .backgroundColor: backgroundColor ?? .gray,
                        .font: font ?? .systemFont(ofSize: 16, weight: .light),
                        .foregroundColor: codeColor ?? .black
                    ],
                    range: .init(location: Int(messageEntityCode.offset), length: Int(messageEntityCode.length))
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        label.font = UltraCoreStyle.systemMessageTextConfig.font
        label.textColor = UltraCoreStyle.systemMessageTextConfig.color
    }
    
}
