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
        $0.cornerRadius = 18
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
            make.top.equalToSuperview().offset(kLowPadding)
            make.left.equalToSuperview().offset(kLowPadding + 2)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(38)
            make.bottom.equalTo(textView.snp.bottom)
            make.right.equalToSuperview().offset(-(kLowPadding + 1))
            make.left.equalTo(textView.snp.right).offset(kMediumPadding - 5)
        }
    }
    
    func setup(message: Message) {
        self.message = message
        if let messagePrefix = messagePrefix {
            self.textView.attributedText = NSAttributedString(string: "\(messagePrefix)\n\(message.text)")
        } else {
            self.textView.attributedText = NSAttributedString(string: message.text)
        }
        self.deliveryDateLabel.text = message.meta.created.dateBy(format: .hourAndMinute)
        self.traitCollectionDidChange(UIScreen.main.traitCollection)
        if #available(iOS 13.0, *) {
            self.container.addInteraction(UIContextMenuInteraction.init(delegate: self))
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        func attributes(for font: UIFont?, textColor: UIColor?) -> [NSAttributedString.Key : Any] {
            var attributes = [NSAttributedString.Key: Any]()
            if let font = font {
                attributes[.font] = font
            }
            if let textColor = textColor {
                attributes[.foregroundColor] = textColor
            }
            return attributes
        }
        if let message = message {
            if message.isIncome {
                self.container.backgroundColor = UltraCoreStyle.incomeMessageCell?.backgroundColor.color
                self.deliveryDateLabel.font = UltraCoreStyle.incomeMessageCell?.deliveryLabelConfig.font
                self.deliveryDateLabel.textColor = UltraCoreStyle.incomeMessageCell?.deliveryLabelConfig.color
                
                self.textView.font = UltraCoreStyle.incomeMessageCell?.textLabelConfig.font
                self.textView.textColor = UltraCoreStyle.incomeMessageCell?.textLabelConfig.color
                let attributedStr = NSMutableAttributedString(
                    string: self.textView.text ?? "",
                    attributes: attributes(
                        for: UltraCoreStyle.incomeMessageCell?.textLabelConfig.font,
                        textColor: UltraCoreStyle.incomeMessageCell?.textLabelConfig.color
                    )
                )
                if let messagePrefix = messagePrefix {
                    let range = NSString(string: attributedStr.string).range(of: messagePrefix)
                    attributedStr.setAttributes(
                        attributes(
                            for: UltraCoreStyle.incomeMessageCell?.contactLabelConfig.font,
                            textColor: UltraCoreStyle.incomeMessageCell?.contactLabelConfig.color),
                        range: range
                    )
                }
                
                self.textView.attributedText = attributedStr
            } else {
                self.container.backgroundColor = UltraCoreStyle.outcomeMessageCell?.backgroundColor.color
                
                self.deliveryDateLabel.font = UltraCoreStyle.outcomeMessageCell?.deliveryLabelConfig.font
                self.deliveryDateLabel.textColor = UltraCoreStyle.outcomeMessageCell?.deliveryLabelConfig.color
                self.textView.font = UltraCoreStyle.outcomeMessageCell?.textLabelConfig.font
                self.textView.textColor = UltraCoreStyle.outcomeMessageCell?.textLabelConfig.color
                self.textView.attributedText = NSAttributedString(
                    string: self.textView.text ?? "",
                    attributes: attributes(
                        for: UltraCoreStyle.outcomeMessageCell?.textLabelConfig.font,
                        textColor: UltraCoreStyle.outcomeMessageCell?.textLabelConfig.color
                    )
                )
            }
            
            if (message.hasPhoto || message.hasVideo), let style = UltraCoreStyle.videoFotoMessageCell {
                self.deliveryDateLabel.font = style.deliveryLabelConfig.font
                self.deliveryDateLabel.textColor = style.deliveryLabelConfig.color
            }
        } else {
            self.container.backgroundColor = UltraCoreStyle.incomeMessageCell?.backgroundColor.color
        }
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
            
            action.append(UIAction(title: MessageStrings.delete.localized, image: messageStyle.delete?.image, attributes: .destructive) { _ in
                self.cellActionCallback?()
                self.longTapCallback?(.delete(message))
            })

            let select = UIAction(title: MessageStrings.select.localized, image: messageStyle.select?.image) { _ in
                self.cellActionCallback?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                    self.longTapCallback?(.select(message))
                })
            }
            
            if message.isIncome,
                (UltraCoreSettings.futureDelegate?.availableToReport(message: message) ?? true) {
                return UIMenu(title: "", children: [UIMenu(options: [.displayInline], children: action), self.makeReportMenu(), select])
            }else {
                return UIMenu(title: "", children: [UIMenu(options: [.displayInline], children: action), select])
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
