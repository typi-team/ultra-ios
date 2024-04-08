//
//  OutcomeFileCell.swift
//  UltraCore
//
//  Created by Slam on 7/18/23.
//

import UIKit
import NVActivityIndicatorView
import RxCocoa
import RxSwift

class OutcomeFileCell : BaseMessageCell {
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    fileprivate let fileIconView: UIImageView = .init({
        $0.image = UltraCoreStyle.outcomeMessageCell?.fileIconImage?.image
        $0.contentMode = .center
    })
    fileprivate let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(
            frame: CGRect(origin: .zero, size: .init(width: 20, height: 20)),
            type: .circleStrokeSpin,
            color: UltraCoreStyle.outcomeMessageCell?.fileCellConfig.loaderTintColor.color,
            padding: 0
        )
        spinner.startAnimating()
        spinner.isHidden = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    fileprivate let fileLabel: RegularFootnote = .init({
        $0.text = MessageStrings.fileWithoutSmile.localized
        $0.textColor = UltraCoreStyle.outcomeMessageCell?.fileCellConfig.fileTextConfig.color
        $0.font = UltraCoreStyle.outcomeMessageCell?.fileCellConfig.fileTextConfig.font
    })
    fileprivate let mediaRepository: MediaRepository = AppSettingsImpl.shared.mediaRepository
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        spinner.isHidden = true
        fileIconView.isHidden = false
    }
    
    override func setupView() {
        super.setupView()

        self.container.addSubview(fileIconView)
        self.container.addSubview(textView)
        self.container.addSubview(fileLabel)
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
        
        self.fileLabel.snp.makeConstraints { make in
            make.bottom.equalTo(fileIconView.snp.bottom)
            make.top.equalTo(textView.snp.bottom).offset(1)
            make.left.equalTo(fileIconView.snp.right).offset(kMediumPadding)
        }

        self.statusView.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(self.fileLabel.snp.right).offset(kLowPadding)
            make.centerY.equalTo(fileLabel.snp.centerY)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(fileLabel.snp.bottom)
            make.centerY.equalTo(statusView.snp.centerY)
        }

        self.spinner.snp.makeConstraints { make in
            make.center.equalTo(fileIconView)
            make.size.equalTo(20)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.textView.text = message.file.fileName
        self.statusView.image = message.statusImage
        self.spinner.isHidden = message.state.delivered == true
    }
    
    override func setupStyle() {
        super.setupStyle()
        self.fileIconView.image = UltraCoreStyle.outcomeMessageCell?.fileIconImage?.image ?? UIImage.named("contact_file_icon")
        bindLoader()
    }
    
    private func bindLoader() {
        let driver = mediaRepository
            .uploadingMedias
            .map { [weak self] requests in
                requests.first(where: { $0.fileID == self?.message?.fileID })
            }
            .map { request in
                guard let request = request else {
                    return false
                }
                return request.fromChunkNumber < request.toChunkNumber
            }
            .distinctUntilChanged()
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: false)
        driver
            .drive { [weak self] isLoading in
                self?.spinner.isHidden = !isLoading
                isLoading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            }
            .disposed(by: disposeBag)
        driver
            .drive(fileIconView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
