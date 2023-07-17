//
//  FilesController.swift
//  UltraCore
//
//  Created by Slam on 6/5/23.
//

import UIKit

enum FilesAction {
    case takePhoto
    case fromGallery
}

class FilesController: BaseViewController<String> {
    
    var resultCallback: ((FilesAction) -> Void)?

    fileprivate let headlineLabel: HeadlineBody = .init({
        $0.textAlignment = .left
        $0.text = "Добавить вложение"
    })

    fileprivate lazy var takePhoto: TextButton = .init({
        $0.setImage(.named("conversation_camera"), for: .normal)
        $0.setTitle("Сделать фото", for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .takePhoto)
        }
    })

    fileprivate lazy var fromGallery: TextButton = .init({
        $0.setImage(.named("conversation_photo"), for: .normal)
        $0.setTitle("Выбрать из галереи", for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .fromGallery)
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

private extension FilesController {
    func handle(action: FilesAction) {
        self.dismiss(animated: true, completion: {
            self.resultCallback?(action)
        })
    }
}
