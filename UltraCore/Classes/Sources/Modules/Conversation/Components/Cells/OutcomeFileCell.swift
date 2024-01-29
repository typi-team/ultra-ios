//
//  OutcomeFileCell.swift
//  UltraCore
//
//  Created by Slam on 7/18/23.
//

import UIKit
import NVActivityIndicatorView

class OutcomeFileCell : BaseMessageCell {
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    fileprivate let fileIconView: UIImageView = .init({
        $0.image = UIImage.named("contact_file_icon")
        $0.contentMode = .center
    })
    fileprivate let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(
            frame: CGRect(origin: .zero, size: .init(width: 30, height: 30)),
            type: .circleStrokeSpin,
            color: .black,
            padding: 0
        )
        spinner.startAnimating()
        spinner.isHidden = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    fileprivate let moneyCaptionlabel: RegularFootnote = .init({ $0.text = MessageStrings.fileWithoutSmile.localized })
    
    override func setupView() {
        super.setupView()

        self.container.addSubview(fileIconView)
        self.container.addSubview(textView)
        self.container.addSubview(moneyCaptionlabel)
        self.container.addSubview(spinner)
        self.container.addSubview(statusView)
        self.container.backgroundColor = .gray200
    }
    
    override func setupConstraints() {
        
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.width.lessThanOrEqualTo(bubbleWidth)
        }
        
        self.fileIconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kMediumPadding)
            make.top.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-kMediumPadding)
            make.width.equalTo(16)
        }
        
        self.textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding)
            make.left.equalTo(fileIconView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(kMediumPadding).offset(-kMediumPadding)
        }
        
        self.moneyCaptionlabel.snp.makeConstraints { make in
            make.bottom.equalTo(fileIconView.snp.bottom)
            make.top.equalTo(textView.snp.bottom).offset(1)
            make.left.equalTo(fileIconView.snp.right).offset(kMediumPadding)
        }

        self.statusView.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(self.moneyCaptionlabel.snp.right).offset(kLowPadding / 2)
            make.centerY.equalTo(moneyCaptionlabel.snp.centerY)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(moneyCaptionlabel.snp.bottom)
            make.centerY.equalTo(statusView.snp.centerY)
        }

        self.spinner.snp.makeConstraints { make in
            make.center.equalTo(fileIconView)
            make.size.equalTo(30)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.textView.text = message.file.fileName
        self.statusView.image = message.statusImage
        self.spinner.isHidden = message.state.delivered == true
        self.fileIconView.isHidden = !self.spinner.isHidden
    }
    
    override func setupStyle() {
        super.setupStyle()
        self.fileIconView.image = UltraCoreStyle.outcomeMessageCell?.fileIconImage?.image ?? UIImage.named("contact_file_icon")
    }
}
