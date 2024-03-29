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
        self.setupStyle()
        self.setupConstraints()
        self.setupInitialData()
        if handleKeyboardTransmission { self.registerKeyboardNotification() }
        if isDebugMode { self.debugInitialData() }
    }
    
    deinit {
        PP.info("Deinit \(String.init(describing: self))")
        if handleKeyboardTransmission {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupStyle()
    }
}


extension UIViewController {
    
    func showInProgressAlert() {
        let alert = UIAlertController.init(title: title, message: BaseStrings.inTheProcessOfRealizationAUniqueFunctionalityMaturesWhichWillAddMagicAndEfficiencyToOurProduct.localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: BaseStrings.close.localized, style: UIAlertAction.Style.cancel))
        self.present(alert, animated: true)
    }
    
    func showAlert(from message: String, with title: String? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: BaseStrings.close.localized, style: UIAlertAction.Style.cancel))
        self.present(alert, animated: true)
    }
    
    func showSettingAlert(from message: String, with title: String? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: BaseStrings.close.localized, style: .cancel))
        alert.addAction(UIAlertAction.init(title: BaseStrings.settings.localized, style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        self.present(alert, animated: true)
    }
    
    @objc func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }
        
        self.changedKeyboard(
            frame: keyboardFrame,
            animationDuration: durationValue,
            animationOptions: UIView.AnimationOptions(rawValue: curveValue << 16)
        )
    }
    
    @objc func changedKeyboard(
        frame: CGRect,
        animationDuration: Double,
        animationOptions: UIView.AnimationOptions
    ) {
        fatalError("implement this methode")
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }
        
        self.changedKeyboard(
            frame: keyboardFrame,
            animationDuration: durationValue,
            animationOptions: UIView.AnimationOptions(rawValue: curveValue << 16)
        )
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        fatalError("implement this methode")
    }

    @objc func debugInitialData() {
        
    }
    
    @objc func setupStyle() {
        self.view.backgroundColor = UltraCoreStyle.controllerBackground?.color
    }
    
    @objc func setupViews() {

        let yourBackImage = UIImage.named( "icon_back_button")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    @objc func setupConstraints() {}
    @objc func setupInitialData() {}
}
