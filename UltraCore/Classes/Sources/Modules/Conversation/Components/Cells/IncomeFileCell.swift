//
//  IncomeFileCell.swift
//  UltraCore
//
//  Created by Slam on 7/18/23.
//

import UIKit
import NVActivityIndicatorView
import RxCocoa
import RxSwift

class IncomeFileCell : BaseMessageCell {
    
    let mediaRepository: MediaRepository = AppSettingsImpl.shared.mediaRepository
    
    fileprivate let fileLabel: RegularFootnote = .init({
        $0.text = MessageStrings.fileWithoutSmile.localized
        $0.textColor = UltraCoreStyle.fileCellConfig.fileTextConfig.color
        $0.font = UltraCoreStyle.fileCellConfig.fileTextConfig.font
    })
    fileprivate let fileIconView: UIImageView = .init({
        $0.image = UIImage.named("contact_file_icon")
        $0.contentMode = .center
    })
    fileprivate let spinner: NVActivityIndicatorView = {
        let spinner = NVActivityIndicatorView(
            frame: CGRect(origin: .zero, size: .init(width: 20, height: 20)),
            type: .circleStrokeSpin,
            color: UltraCoreStyle.fileCellConfig.loaderTintColor.color,
            padding: 0
        )
        spinner.startAnimating()
        spinner.isHidden = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.spinner.isHidden = true
        fileIconView.isHidden = false
    }
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(fileIconView)
        self.container.addSubview(spinner)
        self.container.addSubview(textView)
        self.container.addSubview(fileLabel)
    }

    override func setupConstraints() {
        
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
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
            make.right.equalToSuperview().offset(-kMediumPadding)
        }
        
        self.fileLabel.snp.makeConstraints { make in
            make.bottom.equalTo(fileIconView.snp.bottom)
            make.top.equalTo(textView.snp.bottom).offset(1)
            make.left.equalTo(fileIconView.snp.right).offset(kMediumPadding)
        }
        
        self.spinner.snp.makeConstraints { make in
            make.center.equalTo(fileIconView)
            make.size.equalTo(20)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(fileLabel.snp.centerY)
            make.right.equalToSuperview().offset(-kMediumPadding)
        }
    }

    override func setup(message: Message) {
        super.setup(message: message)
        self.textView.text = message.file.fileName
        bindLoader()
    }

    private func bindLoader() {
        let driver = self.mediaRepository
            .downloadingImages
            .asObservable()
            .map { [weak self] downloadRequest in
                downloadRequest.first(where: { $0.fileID == self?.message?.fileID })
            }
            .map { request -> Bool in
                guard let request = request else {
                    return false
                }
                let isLoading = request.fromChunkNumber < request.toChunkNumber
                return isLoading
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
