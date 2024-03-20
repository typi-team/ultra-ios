//
//  ConversationEmptyViewContainer.swift
//  UltraCore
//
//  Created by Typi on 20.03.2024.
//

import Foundation
import UIKit

class ConversationEmptyViewContainer: UIView {
    private let emptyView: UIView
    
    init(emptyView: UIView) {
        self.emptyView = emptyView
        super.init(frame: .zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        self.emptyView = .init()
        super.init(coder: coder)
        configureViews()
    }
    
    private func configureViews() {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyView)
        emptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setSubviewOffset(y: CGFloat) {
        emptyView.transform = .init(translationX: 0, y: y)
    }
}
