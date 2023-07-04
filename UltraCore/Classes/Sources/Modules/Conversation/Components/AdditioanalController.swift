//
//  AdditioanalController.swift
//  UltraCore
//
//  Created by Slam on 7/3/23.
//

import UIKit

enum AdditioanalAction {
    case money_tranfer
}

class AdditioanalController: BaseViewController<String> {
    
    var resultCallback: ((AdditioanalAction) -> Void)?

    fileprivate let headlineLabel: HeadlineBody = .init({
        $0.textAlignment = .left
        $0.text = "Отправить"
    })

    fileprivate lazy var takePhoto: TextButton = .init({
        $0.titleLabel?.numberOfLines = 0
        $0.setImage(.named("conversation_money_logo_icon"), for: .normal)
        
        let boldFontAttributes: [NSAttributedString.Key: Any] = [ .font: UIFont.defaultRegularBody,
                                                                  .foregroundColor : UIColor.gray700 ]
        let smallFontAttributes: [NSAttributedString.Key: Any] = [ .font: UIFont.defaultRegularFootnote,
                                                                   .foregroundColor : UIColor.gray500]

        let boldText = "Внутри Банка"
        let smallText = "Отправить клиенту FreedomBank"
        let titleText = "\(boldText)\n\(smallText)"

        let attributedTitle = NSMutableAttributedString(string: titleText)
        attributedTitle.addAttributes(boldFontAttributes, range: NSRange(location: 0, length: boldText.count))
        attributedTitle.addAttributes(smallFontAttributes, range: NSRange(location: boldText.count + 1, length: smallText.count))
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .money_tranfer)
        }
    })

    fileprivate lazy var stackView: UIStackView = .init {
        $0.axis = .vertical
        $0.spacing = kLowPadding
        $0.addArrangedSubview(headlineLabel)
        $0.setCustomSpacing(kHeadlinePadding, after: headlineLabel)
        $0.addArrangedSubview(takePhoto)
    }
    
    override func setupViews() {
        super.setupViews()
        self.view.addSubview(stackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kHeadlinePadding + kMediumPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-kLowPadding)
        }
    }
}

private extension AdditioanalController {
    func handle(action: AdditioanalAction) {
        self.dismiss(animated: true, completion: {
            self.resultCallback?(action)
        })
    }
}

