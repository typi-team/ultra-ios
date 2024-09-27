//
//  BaseMessageCell.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import UIKit
import RxSwift


struct MediaMessageConstants {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
}

enum MessageMenuAction {
    case select(Message)
    case delete(Message)
    case reply(Message)
    case copy(Message)
    case reportDefined(message: Message, type: ComplainTypeEnum)
}

class BaseMessageCell: BaseCell {
    fileprivate lazy var cellAction = UITapGestureRecognizer.init(target: self, action: #selector(self.handleCellPress(_:)))
    
    var messagePrefix: String?
    var message: Message?
    var canDelete: Bool = true
    var canReport: Bool = true
    var cellActionCallback: (() -> Void)?
    var actionCallback: ((Message) -> Void)?
    var longTapCallback:((MessageMenuAction) -> Void)?
    lazy var disposeBag: DisposeBag = .init()
    lazy var constants: MediaMessageConstants = .init(maxWidth: 300, maxHeight: 200)
    lazy var bubbleWidth = UIScreen.main.bounds.width - kHeadlinePadding * 4
    
    let textView: AttributedLabel = .init(frame: .zero)
    
    let deliveryDateLabel: UILabel = .init({
        $0.textAlignment = .right
    })
    
    let container: UIView = .init({
        $0.cornerRadius = 12
        $0.backgroundColor = .clear
    })
    
    override func setupView() {
        super.setupView()
        self.contentView.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(textView)
        self.container.addSubview(deliveryDateLabel)
        
        self.additioanSetup()
    }
    
    override func additioanSetup() {
        super.additioanSetup()
        
        self.selectionStyle = .gray
        cellAction.cancelsTouchesInView = false
        self.contentView.addGestureRecognizer(cellAction)
        
        if #available(iOS 13.0, *) {
            
        } else {
            let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(self.handleLongPress(_:)))
            longTap.minimumPressDuration = 0.3
            self.container.addGestureRecognizer(longTap)
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapPress(_:)))
        tap.cancelsTouchesInView = false
        self.container.addGestureRecognizer(tap)
        
        self.selectedBackgroundView = UIView({
            $0.backgroundColor = .clear
        })
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.width.lessThanOrEqualTo(bubbleWidth)
        }

        self.textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(kLowPadding)
            make.right.equalToSuperview().offset(-8)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-4)
            make.left.greaterThanOrEqualTo(container).offset(4)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func setup(message: Message) {
        self.message = message
        message.isIncome ? stylizeForIncome() : stylizeForOutcome()
        
        self.textView.attributedText = attributedText(for: message)
        self.deliveryDateLabel.text = message.meta.created.dateBy(format: .hourAndMinute)
        if #available(iOS 13.0, *) {
            self.container.addInteraction(UIContextMenuInteraction.init(delegate: self))
        }
    }
    
    private func commonStyling() {
        guard let message = message else { return }
        if (message.hasPhoto || message.hasVideo), let style = UltraCoreStyle.videoFotoMessageCell {
            deliveryDateLabel.font = style.deliveryLabelConfig.font
            deliveryDateLabel.textColor = style.deliveryLabelConfig.color
        }
    }
    
    private func textFont(for message: Message) -> UIFont? {
        message.isIncome ? UltraCoreStyle.incomeMessageCell?.textLabelConfig.font : UltraCoreStyle.outcomeMessageCell?.textLabelConfig.font
    }
    
    private func textColor(for message: Message) -> UIColor? {
        message.isIncome ? UltraCoreStyle.incomeMessageCell?.textLabelConfig.color : UltraCoreStyle.outcomeMessageCell?.textLabelConfig.color
    }
    
    private func stylizeForIncome() {
        commonStyling()
        self.textView.hyperlinkAttributes = [
            .foregroundColor: UltraCoreStyle.incomeMessageCell?.linkColor.color ?? .systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        self.container.backgroundColor = UltraCoreStyle.incomeMessageCell?.backgroundColor.color
        self.deliveryDateLabel.font = UltraCoreStyle.incomeMessageCell?.deliveryLabelConfig.font
        self.deliveryDateLabel.textColor = UltraCoreStyle.incomeMessageCell?.deliveryLabelConfig.color
    }
    
    private func stylizeForOutcome() {
        commonStyling()
        self.textView.hyperlinkAttributes = [
            .foregroundColor: UltraCoreStyle.outcomeMessageCell?.linkColor.color ?? .systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        self.container.backgroundColor = UltraCoreStyle.outcomeMessageCell?.backgroundColor.color
        self.deliveryDateLabel.font = UltraCoreStyle.outcomeMessageCell?.deliveryLabelConfig.font
        self.deliveryDateLabel.textColor = UltraCoreStyle.outcomeMessageCell?.deliveryLabelConfig.color
    }
    
    private func attributedText(for message: Message) -> NSAttributedString {
        let font = message.isIncome ? UltraCoreStyle.incomeMessageCell?.textLabelConfig.font : UltraCoreStyle.outcomeMessageCell?.textLabelConfig.font
        let textColor = message.isIncome ? UltraCoreStyle.incomeMessageCell?.textLabelConfig.color : UltraCoreStyle.outcomeMessageCell?.textLabelConfig.color
        guard !message.entities.isEmpty else {
            return NSAttributedString(
                string: message.text,
                attributes: attributes(
                    for: font,
                    textColor: textColor
                )
            )
        }
        
        let mutable = NSMutableAttributedString(string: message.text, attributes: attributes(for: font, textColor: textColor))
        
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
        
        guard self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        
        guard let message = message else {
            self.container.backgroundColor = UltraCoreStyle.incomeMessageCell?.backgroundColor.color
            return
        }
        if message.isIncome {
            stylizeForIncome()
        } else {
            stylizeForOutcome()
        }
        if let attributedText = textView.attributedText {
            let updatedText = NSMutableAttributedString(attributedString: attributedText)
            if let font = textFont(for: message) {
                updatedText.setBaseFont(baseFont: font)
            }
            if let textColor = textColor(for: message) {
                updatedText.setAttributes([.foregroundColor: textColor], range: NSRange(location: 0, length: updatedText.length))
            }
        }
        
        commonStyling()
    }
}

extension BaseMessageCell: UIContextMenuInteractionDelegate {
    
    var messageStyle: MessageCellStyle { UltraCoreStyle.messageCellStyle }
    var reportStyle: ReportViewStyle { UltraCoreStyle.reportViewStyle }
    
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configuration: UIContextMenuConfiguration, dismissalPreviewForItemWithIdentifier identifier: NSCopying) -> UITargetedPreview? {
        cellActionCallback?()
        return nil
    }
    
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let message else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self, message] _ -> UIMenu? in
            guard let `self` = self else { return nil }
            var action: [UIAction] = []
            if  !message.hasAttachment {
                action.append(UIAction(title: MessageStrings.copy.localized, image: messageStyle.copy?.image) { _ in
                    self.longTapCallback?(.copy(message))
                })
            }
            
            if canDelete {
                action.append(UIAction(title: MessageStrings.delete.localized, image: messageStyle.delete?.image, attributes: .destructive) { _ in
                    self.cellActionCallback?()
                    self.longTapCallback?(.delete(message))
                })
            }

            let select = UIAction(title: MessageStrings.select.localized, image: messageStyle.select?.image) { _ in
                self.cellActionCallback?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                    self.longTapCallback?(.select(message))
                })
            }
            
            if 
                message.isIncome,
                canReport,
                (UltraCoreSettings.futureDelegate?.availableToReport(message: message) ?? true)
            {
                if canDelete {
                    return UIMenu(title: "", children: [UIMenu(options: [.displayInline], children: action), self.makeReportMenu(), select])
                } else {
                    return UIMenu(title: "", children: [UIMenu(options: [.displayInline], children: action), self.makeReportMenu()])
                }
            } else {
                if canDelete {
                    return UIMenu(title: "", children: [UIMenu(options: [.displayInline], children: action), select])
                } else {
                    return UIMenu(title: "", children: [UIMenu(options: [.displayInline], children: action)])
                }
            }
            
            
        }
    }
    
    @available(iOS 13.0, *)
    func makeReportMenu() -> UIMenu {
        let spam = UIAction(title: MessageStrings.spam.localized,
                            image: reportStyle.spam?.image,
                            identifier: nil) { [weak self] _ in
            guard let `self` = self, let message = self.message else {
                return
            }
            self.longTapCallback?(.reportDefined(message: message, type: ComplainTypeEnum.spam))
        }

        let personalData = UIAction(title: MessageStrings.personalData.localized,
                                    image: reportStyle.personalData?.image,
                                    identifier: nil) { [weak self] _ in
            guard let `self` = self, let message = self.message else {
                return
            }
            self.longTapCallback?(.reportDefined(message: message, type: ComplainTypeEnum.personalData))
        }

        let fraud = UIAction(title: MessageStrings.fraud.localized,
                             image: reportStyle.fraud?.image,
                             identifier: nil,
                             discoverabilityTitle: "To share the iamge to any social media") { [weak self] _ in
            guard let `self` = self, let message = self.message else {
                return
            }
            self.longTapCallback?(.reportDefined(message: message, type: ComplainTypeEnum.fraud))
        }

        let impositionOfServices = UIAction(title: MessageStrings.impositionOfServices.localized,
                                            image: reportStyle.impositionOfServices?.image,
                                            identifier: nil,
                                            discoverabilityTitle: nil,

                                            handler: { [weak self] _ in
                                                guard let `self` = self, let message = self.message else {
                                                    return
                                                }
                                                self.longTapCallback?(.reportDefined(message: message, type: ComplainTypeEnum.serviceImposition))
                                            })
        let insult = UIAction(title: MessageStrings.insult.localized,
                              image: reportStyle.insult?.image,
                              identifier: nil,
                              discoverabilityTitle: nil,

                              handler: { [weak self] _ in
                                  guard let `self` = self, let message = self.message else {
                                      return
                                  }
                                  self.longTapCallback?(.reportDefined(message: message, type: ComplainTypeEnum.inappropriate))
                              })
        let other = UIAction(title: MessageStrings.other.localized,
                             image: reportStyle.other?.image,
                             identifier: nil,
                             discoverabilityTitle: nil,

                             handler: { [weak self] _ in
                                 guard let `self` = self, let message = self.message else {
                                     return
                                 }
            self.longTapCallback?(.reportDefined(message: message, type: .other))
                             })

        return UIMenu(title: MessageStrings.report.localized,
                      image: reportStyle.report?.image,
                      children: [spam, personalData, fraud, impositionOfServices, insult, other])
    }
}



extension BaseMessageCell {
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let message = self.message, sender.state == .began else {
            return
        }
        
        self.longTapCallback?(.select(message))
     }
    
    @objc func handleTapPress(_ sender: UILongPressGestureRecognizer) {
        guard let message = self.message else {
            return
        }
        self.actionCallback?(message)
     }
    
    @objc func handleCellPress(_ sender: UILongPressGestureRecognizer) {
        self.cellActionCallback?()
     }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.container.isUserInteractionEnabled = !editing
        self.contentView.isUserInteractionEnabled = !editing
    }
}

extension NSMutableAttributedString {
    func setBaseFont(baseFont: UIFont, preserveFontSizes: Bool = false) {
        let baseDescriptor = baseFont.fontDescriptor
        let wholeRange = NSRange(location: 0, length: length)
        beginEditing()
        enumerateAttribute(.font, in: wholeRange, options: []) { object, range, _ in
            guard let font = object as? UIFont else { return }
            // Instantiate a font with our base font's family, but with the current range's traits
            let traits = font.fontDescriptor.symbolicTraits
            guard let descriptor = baseDescriptor.withSymbolicTraits(traits) else { return }
            let newSize = preserveFontSizes ? descriptor.pointSize : baseDescriptor.pointSize
            let newFont = UIFont(descriptor: descriptor, size: newSize)
            self.removeAttribute(.font, range: range)
            self.addAttribute(.font, value: newFont, range: range)
        }
        endEditing()
    }
}
