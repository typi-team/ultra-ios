//
//  BaseViewController.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit
import RxSwift

let kTypingMinInterval: Double = 3
let kHeadlinePadding: CGFloat = 24
let kMediumPadding: CGFloat = 16
let kButtonHeight: CGFloat = 56
let kLowPadding: CGFloat = 8


class BaseViewController<T>: UIViewController {
    var presenter: T?
    var isDebugMode: Bool = true
    let disposeBag: DisposeBag = .init()
    var handleKeyboardTransmission: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupConstraints()
        self.setupInitialData()
        if handleKeyboardTransmission { self.registerKeyboardNotification() }
        if isDebugMode { self.debugInitialData() }
    }
    
    deinit {
        Logger.info("Deinit \(String.init(describing: self))")
        if handleKeyboardTransmission {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
}


extension UIViewController {
    
    @objc func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.changed(keyboard: keyboardFrame.height)
    }
    
    @objc func changed(keyboard height: CGFloat) {
        fatalError("implement this methode")
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // клавиатура закрывается, здесь можно выполнить какие-то действия
    }

    @objc func debugInitialData() {
        
    }
    @objc func setupViews() {
        self.view.backgroundColor = .gray100
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    @objc func setupConstraints() {}
    @objc func setupInitialData() {}
}
