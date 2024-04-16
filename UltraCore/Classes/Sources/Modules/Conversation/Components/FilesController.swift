//
//  FilesController.swift
//  UltraCore
//
//  Created by Slam on 6/5/23.
//

import UIKit

enum FilesAction {
    case contact
    case document
    case takePhoto
    case fromGallery
    case location
}

class FilesController: BaseViewController<String> {
    
    var resultCallback: ((FilesAction) -> Void)?

    fileprivate let headlineLabel: Title3Label = .init({
        $0.textAlignment = .left
        $0.text = ConversationStrings.addAttachment.localized
    })

    fileprivate lazy var takePhoto: TextButton = .init({
        $0.setTitle(ConversationStrings.toMakeAPhoto.localized, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .takePhoto)
        }
    })

    fileprivate var style: FilesControllerConfig? = UltraCoreStyle.filePageConfig
    
    fileprivate lazy var fromGallery: TextButton = .init({
        $0.setTitle(ConversationStrings.selectionFromLibrary.localized, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .fromGallery)
        }
    })
    
    fileprivate lazy var document: TextButton = .init({
        $0.setTitle(ConversationStrings.selectDocument.localized, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .document)
        }
    })
    
    fileprivate lazy var contact: TextButton = .init({
        $0.setTitle(ConversationStrings.contact.localized, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .contact)
        }
    })
    
    fileprivate lazy var location: TextButton = .init({
        $0.setTitle(ConversationStrings.location.localized, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .location)
        }
    })

    fileprivate lazy var stackView: UIStackView = .init {
        $0.axis = .vertical
        $0.spacing = kLowPadding
        $0.addArrangedSubview(headlineLabel)
        $0.setCustomSpacing(kHeadlinePadding, after: headlineLabel)
        
        $0.addArrangedSubview(takePhoto)
        $0.setCustomSpacing(kLowPadding * 3, after: takePhoto)
        $0.addArrangedSubview(fromGallery)
        $0.setCustomSpacing(kLowPadding * 3, after: fromGallery)
        $0.addArrangedSubview(document)
        $0.setCustomSpacing(kLowPadding * 3, after: document)
        
        if UltraCoreSettings.futureDelegate?.availableToContact() ?? false {
            $0.addArrangedSubview(contact)
            $0.setCustomSpacing(kLowPadding * 3, after: contact)
        }
        
        if UltraCoreSettings.futureDelegate?.availableToContact() ?? false {
            $0.addArrangedSubview(location)
            $0.setCustomSpacing(kLowPadding * 3, after: location)
        }
    }
    
    private var bottomInset: CGFloat {
        presentingViewController?.view.safeAreaInsets.bottom ?? 0
    }
    
    override func setupViews() {
        super.setupViews()
        self.view.addSubview(stackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.stackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(kHeadlinePadding)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-bottomInset)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        if let style = self.style {
            self.takePhoto.setImage(style.takePhotoImage.image, for: .normal)
            self.fromGallery.setImage(style.fromGalleryImage.image, for: .normal)
            self.document.setImage(style.documentImage.image, for: .normal)
            self.contact.setImage(style.contactImage.image, for: .normal)
            self.location.setImage(style.locationImage.image, for: .normal)
        }
    }
}

private extension FilesController {
    func handle(action: FilesAction) {
        self.dismiss(animated: true, completion: {
            self.resultCallback?(action)
        })
    }
}
