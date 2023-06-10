//
//  ConversationViewController.swift
//  Pods
//
//  Created by Slam on 4/25/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import RxCocoa
import RxSwift
import UIKit

final class ConversationViewController: BaseViewController<ConversationPresenterInterface>, (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    // MARK: - Properties
    
    let sheetTransitioningDelegate = SheetTransitioningDelegate()

    fileprivate var isDrawingTable: Bool = false
    
    // MARK: - Views
    
    fileprivate let navigationDivider: UIView = .init({
        $0.backgroundColor = .gray200
    })
    
    private lazy var tableView: UITableView = .init {[weak self] tableView in
        guard let `self` = self else { return }
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false 
        tableView.registerCell(type: BaseMessageCell.self)
        tableView.registerCell(type: IncomeMessageCell.self)
        tableView.registerCell(type: IncomingMediaCell.self)
        tableView.registerCell(type: OutgoingMessageCell.self)
        tableView.registerCell(type: OutgoingMediaCell.self)
        tableView.backgroundColor = self.view.backgroundColor
        tableView.contentInset = .init(top: kMediumPadding, left: 0, bottom: 0, right: 0)
        tableView.backgroundView = UIImageView({
            $0.contentMode = .scaleAspectFill
            $0.image = .named("conversation_background")
        })
    }
    
    fileprivate lazy var messageHeadline: SubHeadline = .init({
        $0.textColor = .gray500
        $0.textAlignment = .center
        $0.isUserInteractionEnabled = false
    })
    private lazy var headline: ProfileNavigationView = .init()
    private lazy var messageInputBar: MessageInputBar = .init({ [weak self] inputBar in
        inputBar.delegate = self
    })
    
    // MARK: - Private Methods
    
    override func setupViews() {
        self.handleKeyboardTransmission = true
        super.setupViews()
        view.addSubview(tableView)
        view.addSubview(messageHeadline)
        view.addSubview(messageInputBar)
        view.addSubview(navigationDivider)
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = .init(customView: self.headline)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.navigationDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.left.right.equalToSuperview()
        }
        
        self.tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(navigationDivider.snp.bottom)
            make.bottom.equalTo(messageInputBar.snp.topMargin).offset(-10)
        }
        
        self.messageHeadline.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(messageInputBar.snp.topMargin).offset(-kMediumPadding)
        }
        
        self.messageInputBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
        }
    }
    
    override func setupInitialData() {
        super.setupInitialData()
        
        self.presenter?
            .messages
            .observe(on: MainScheduler.instance)
            .do(onNext: {[weak self] messages in
                    self?.messageHeadline.text = messages.isEmpty ? "В этом чате нет сообщений" : ""
            })
            .do(onNext: { [weak self] result in
                guard let `self` = self, !self.isDrawingTable else {
                    return
                }
                self.isDrawingTable = true
                let isEmpty = self.tableView.numberOfRows(inSection: 0) - 1 <= 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    
                    let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
                    if lastRowIndex < 0 { return }
                    let indexPath = IndexPath(row: lastRowIndex, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: !isEmpty)
                    self.isDrawingTable = false
                })
            })
            .bind(to: tableView.rx.items) { tableView, _, message in
                if message.isIncome && message.photo.fileID != "" {
                    let cell: IncomingMediaCell = tableView.dequeueCell()
                    cell.setup(message: message)
                    return cell
                } else if !message.isIncome && message.photo.fileID != "" {
                    let cell: OutgoingMediaCell = tableView.dequeueCell()
                    cell.setup(message: message)
                    return cell
                } else if message.isIncome {
                    let cell: IncomeMessageCell = tableView.dequeueCell()
                    cell.setup(message: message)
                    return cell
                } else {
                    let cell: OutgoingMessageCell = tableView.dequeueCell()
                    cell.setup(message: message)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        self.presenter?.viewDidLoad()
    }
    
    override func changed(keyboard height: CGFloat) {
        
        if let indexPath = self.tableView.indexPathsForVisibleRows?.last {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            })
        }
        
        self.messageInputBar.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(height > 0 ? -(height - 36) : 0)
        }
    }
}

    // MARK: - UITextViewDelegate

extension ConversationViewController: MessageInputBarDelegate {
    
    func pressedPlus(in view: MessageInputBar) {
        let viewController = FilesController()
        viewController.resultCallback = {[weak self] action in
            guard let `self` = self else { return }
            switch action {
            case .fromGallery: self.openMedia(type: .photoLibrary)
            case .takePhoto: self.openMedia(type: .camera)
            }
        }
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = sheetTransitioningDelegate
        present(viewController, animated: true)
    }
    
    func pressedDone(in view: MessageInputBar) {
        self.view.endEditing(true)
    }
    
    func typing(is active: Bool) {
        self.presenter?.typing(is: active)
    }
    
    func exchanges() {
        self.showAlert(from: "Данная функция еще в разработке")
    }
    
    func micro(isActivated: Bool) {
        self.showAlert(from: "Данная функция еще в разработке")
    }
    
    func message(text: String) {
        self.presenter?.send(message: text)
    }
}

// MARK: - Extensions -

extension ConversationViewController: ConversationViewInterface {
    
    func display(is typing: UserTypingWithDate) {
        self.headline.setup(user: typing)
    }
    
    func setup(conversation: Conversation) {
        self.headline.setup(conversation: conversation)
    }
}


private extension ConversationViewController {
    func openMedia(type: UIImagePickerController.SourceType) {
        self.present(UIImagePickerController({
            $0.delegate = self
            $0.sourceType = type
        }), animated: true)
    }
}


extension ConversationViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: {
            guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage,
                  let data = UIImagePNGRepresentation(image) else {
                 return
            }
            self.presenter?.upload(file: .init(data: data, width: image.size.width, height: image.size.height, mime: "image/png"))
        })
    }
}
