//
//  ProfileNavigationView.swift
//  UltraCore
//
//  Created by Slam on 5/10/23.
//

import Foundation

class ProfileNavigationView: UIView {
    
    fileprivate let headlineText: HeadlineBody = .init()
    fileprivate let sublineText: RegularFootnote = .init()
    
    fileprivate let avatarImageView: UIImageView = .init {
        $0.borderWidth = 1
        $0.cornerRadius = 22
        $0.frame.size = .init(width: 40, height: 40)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.setupConstraints()
    }
    
    func setupConstraints() {
        self.avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        self.headlineText.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(self.avatarImageView.snp.top)
            make.left.equalTo(self.avatarImageView.snp.right).offset(kMediumPadding)
        }
        
        self.sublineText.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.avatarImageView.snp.bottom)
            make.top.equalTo(self.headlineText.snp.bottom).offset(kLowPadding)
            make.left.equalTo(self.avatarImageView.snp.right).offset(kMediumPadding)
        }
    }
    
    func setupView() {
        self.addSubview(sublineText)
        self.addSubview(headlineText)
        self.addSubview(avatarImageView)
    }
    
    func setup(conversation: Conversation) {
        self.avatarImageView.loadImage(by: nil, placeholder: .initial(text: conversation.title))
        self.headlineText.text = conversation.title
        self.sublineText.text = conversation.lastMessage?.description
        
    }
}
