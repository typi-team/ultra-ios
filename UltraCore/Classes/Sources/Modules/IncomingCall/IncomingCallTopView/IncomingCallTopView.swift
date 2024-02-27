//
//  IncomingCallTopView.swift
//  UltraCore-UltraCore
//
//  Created by Typi on 27.02.2024.
//

import UIKit

class IncomingCallTopView: UIView {
    static var callWindow: UIWindow?
    
    private enum Constants {
        static let labelHeight: CGFloat = 22
        static let bottomPadding: CGFloat = 2
    }
    
    var onReturnToCall: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customize()
    }
    
    private func customize() {
        let labelHeight = Constants.labelHeight
        let font: UIFont = .systemFont(ofSize: 15)
        let textColor: UIColor = .white
        let buttonTitle: String = "Touch to return to the call"
        backgroundColor = .green500
        clipsToBounds = true
        let label = UILabel(
            frame: .init(x: 0, y: frame.height - labelHeight - Constants.bottomPadding, width: frame.width, height: labelHeight)
        )
        label.textAlignment = .center
        label.font = font
        label.textColor = textColor
        label.text = buttonTitle
        let button = UIButton(frame: frame)
        button.addTarget(self, action: #selector(didTapCall), for: .touchUpInside)
        addSubview(label)
        addSubview(button)
    }
    
    private static func topInsets() -> CGFloat {
        if let topSafeAreaInset = UIApplication.shared.keyWindow?.safeAreaInsets.top {
            return topSafeAreaInset + Constants.labelHeight
        } else {
            return UIApplication.shared.statusBarFrame.height + Constants.labelHeight
        }
    }
    
    @objc private func didTapCall() {
        onReturnToCall?()
    }
    
    static func show(onReturnToCall: (() -> Void)?) {
        let frame = CGRect(origin: .zero, size: .init(width: UIScreen.main.bounds.width, height: topInsets()))
        if callWindow == nil {
            callWindow = UIWindow(frame: frame)
        }
        if let windowLevel = UIApplication.shared.delegate?.window??.windowLevel {
            callWindow?.windowLevel = windowLevel + 1
        } else {
            callWindow?.windowLevel = UIWindow.Level(0)
        }
        callWindow?.isHidden = false
        let callTopView = IncomingCallTopView(frame: frame)
        callTopView.onReturnToCall = onReturnToCall
        callWindow?.addSubview(callTopView)
        callWindow?.transform = CGAffineTransform(translationX: 0, y: -frame.height)
        UIView.animate(withDuration: 0.3) {
            callWindow?.transform = CGAffineTransformIdentity
            if let keyWindow = UIApplication.shared.delegate?.window {
                keyWindow?.frame = CGRect(
                    origin: .init(x: 0, y: frame.height - 44),
                    size: .init(width: keyWindow?.bounds.size.width ?? 0, height: (keyWindow?.bounds.size.height ?? 0) - frame.height + 44)
                )
            }
        }
    }
    
    static func hide(completion: @escaping (() -> Void)) {
        guard callWindow != nil else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            callWindow?.transform = CGAffineTransform(translationX: 0, y: -topInsets())
            if let keyWindow = UIApplication.shared.delegate?.window {
                keyWindow?.frame = UIScreen.main.bounds
            }
        } completion: { _ in
            callWindow?.isHidden = true
            callWindow = nil
            completion()
        }
    }
    
}
