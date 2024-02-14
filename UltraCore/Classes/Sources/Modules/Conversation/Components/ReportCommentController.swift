//
//  ReportCommentController.swift
//  UltraCore
//
//  Created by Slam on 1/7/24.
//

import Foundation


class ReportCommentController: BaseViewController<String> {
    
    fileprivate lazy var style: ReportCommentControllerStyle? = UltraCoreStyle.reportCommentControllerStyle
    
    var saveAction: ((String) -> Void)?
    
    fileprivate let image: UIImageView = .init {
        $0.contentMode = .scaleAspectFit
    }
    
    fileprivate let headlineLabel: UILabel = .init({
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = MessageStrings.additionalInformationInComments.localized
    })
    
    fileprivate lazy var textField: UITextField = PaddingTextField.init({
        $0.padding = UIEdgeInsets(top: kMediumPadding, left: kLowPadding
                                  , bottom: kMediumPadding, right: kLowPadding)
        $0.cornerRadius = kLowPadding
        $0.placeholder = MessageStrings.comment.localized
        $0.returnKeyType = .done
        $0.delegate = self
        
        $0.rightView = UIButton({
            
            $0.setImage(.named("conversation_erase"), for: .normal)
            $0.addAction { [weak self] in
                guard let `self` = self else { return }
                self.textField.text = ""
            }
        })
        
        $0.rightViewMode = .always
    })

    fileprivate lazy var saveButton: ElevatedButton = .init({
        $0.titleLabel?.numberOfLines = 0
        $0.backgroundColor = .green500
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle(MessageStrings.report.localized.capitalized, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: {
                self.saveAction?(self.textField.text ?? "")
            })
        }
    })
    
    fileprivate lazy var cancelButton: ElevatedButton = .init({
        $0.titleLabel?.numberOfLines = 0
        $0.backgroundColor = .white
        $0.setTitleColor(UltraCoreStyle.elevatedButtonTint?.color, for: .normal)
        $0.setTitle(EditActionStrings.cancel.localized.capitalized, for: .normal)
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }
    })

    fileprivate lazy var stackView: UIStackView = .init {[weak self] stack in
        guard let `self` = self else { return }
        stack.axis = .vertical
        stack.spacing = kLowPadding
        
        stack.addArrangedSubview(image)
        stack.setCustomSpacing(kHeadlinePadding, after: image)
        
        stack.addArrangedSubview(headlineLabel)
        stack.setCustomSpacing(kHeadlinePadding, after: headlineLabel)
        
        
        stack.addArrangedSubview(textField)
        stack.setCustomSpacing(kHeadlinePadding, after: textField)
        
        stack.addArrangedSubview(saveButton)
        stack.setCustomSpacing(kHeadlinePadding, after: saveButton)
    
        
        stack.addArrangedSubview(cancelButton)
        stack.setCustomSpacing(kHeadlinePadding, after: cancelButton)
    }
    
    override func setupViews() {
        super.setupViews()
        self.view.addSubview(stackView)
        self.handleKeyboardTransmission = true
        self.stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endTyping(_:))))
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kHeadlinePadding + kMediumPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-kLowPadding)
        }
        
        self.image.snp.makeConstraints { make in
            make.height.equalTo(141)
        }
        [cancelButton, textField, saveButton].forEach({
            $0.snp.makeConstraints({
                $0.height.equalTo(56)
            })
        })
    }
    
    
    override func setupStyle() {
        super.setupStyle()
        
        self.image.image = style?.headlineImage.image
        self.view.backgroundColor = style?.backgroundColor.color
        
        self.saveButton.backgroundColor = style?.reportButtonConfig.backgroundColor.color
        self.saveButton.setTitleColor(style?.reportButtonConfig.titleConfig.color, for: .normal)
        self.saveButton.titleLabel?.font = style?.reportButtonConfig.titleConfig.font
        
        self.cancelButton.backgroundColor = style?.cancelButtonConfig.backgroundColor.color
        self.cancelButton.setTitleColor(style?.cancelButtonConfig.titleConfig.color, for: .normal)
        self.cancelButton.titleLabel?.font = style?.cancelButtonConfig.titleConfig.font
        
        self.textField.font = style?.textFieldConfig.font
        self.textField.tintColor = style?.textFieldConfig.color
        self.textField.textColor = style?.textFieldConfig.color
        self.textField.backgroundColor = style?.textFieldBackgroundColor.color
        
        self.headlineLabel.font = style?.headlineConfig.font
        self.headlineLabel.textColor = style?.headlineConfig.color
    }
    
    override func changedKeyboard(
        frame: CGRect,
        animationDuration: Double,
        animationOptions: UIView.AnimationOptions
    ) {
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            self.view.frame.origin.y = UIScreen.main.bounds.height - self.view.frame.height - frame.height
        }
    }
}


extension ReportCommentController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
fileprivate extension ReportCommentController {
    @objc func endTyping(_ sender: Any) {
        self.stackView.endEditing(true)
    }
}
