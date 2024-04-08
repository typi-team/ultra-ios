//
//  EditActionBottomBar.swift
//  UltraCore
//
//  Created by Slam on 7/17/23.
//

import Foundation
protocol EditActionBottomBarDelegate: AnyObject {
    func delete()
    func share()
    func reply()
}

class EditActionBottomBar: UIView {
    
    private var style: MessageInputBarConfig? { UltraCoreStyle.mesageInputBarConfig }
    
    weak var delegate:EditActionBottomBarDelegate?
    
    fileprivate lazy var stackView: UIStackView = .init({
        $0.axis = .horizontal
        $0.spacing = kHeadlinePadding
        $0.distribution = .fillEqually
    })
    
    fileprivate lazy var trashButton: UIButton = .init({
        $0.setImage(UltraCoreStyle.editActionBottomBar.trashImage?.image, for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self else {
                 return
            }
            self.delegate?.delete()
        }
    })
    
    fileprivate lazy var shareButton: UIButton = .init({
        $0.setImage(UltraCoreStyle.editActionBottomBar.shareImage?.image, for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self else {
                 return
            }
            self.delegate?.share()
        }
    })
    
    fileprivate lazy var replyButton: UIButton = .init({
        $0.setImage(UltraCoreStyle.editActionBottomBar.replyImage?.image, for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self else {
                 return
            }
            self.delegate?.reply()
        }
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupConstraints()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupStyle()
    }
    
    
}

private extension EditActionBottomBar {
    
    func setupStyle() {
        self.backgroundColor = style?.background.color
    }
    
    func setupViews() {
        self.addSubview(stackView)
        self.backgroundColor = .gray100
        self.stackView.addArrangedSubview(self.trashButton)
//        self.stackView.addArrangedSubview(self.shareButton)
//        self.stackView.addArrangedSubview(self.replyButton)
        self.setupStyle()
    }
    
    func setupConstraints() {
        self.stackView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
}
