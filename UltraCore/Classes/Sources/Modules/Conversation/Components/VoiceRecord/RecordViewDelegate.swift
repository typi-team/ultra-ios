//
//  RecordViewDelegate.swift
//  UltraCore
//
//  Created by Slam on 10/24/23.
//

@objc public protocol RecordViewDelegate {
    func onStart()
    func onCancel()
    func onFinished(duration: CGFloat)
    @objc optional func onAnimationEnd()

}
