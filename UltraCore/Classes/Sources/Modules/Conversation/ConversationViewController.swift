//
//  ConversationViewController.swift
//  Pods
//
//  Created by Slam on 4/25/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import RxCocoa
import RxSwift
import QuickLook

final class ConversationViewController: BaseViewController<ConversationPresenterInterface>, (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    // MARK: - Properties
    
    let sheetTransitioningDelegate = SheetTransitioningDelegate()
    let moneyTransitioningDelegate = SheetTransitioningDelegate()
    fileprivate var mediaItem: URL?
    fileprivate var isDrawingTable: Bool = false
    
    // MARK: - Views
    fileprivate lazy var refreshControl = UIRefreshControl{
        $0.addAction(for: .valueChanged, {[weak self] in
            guard let `self` = self,
                  let cell = self.tableView.visibleCells.first as? BaseMessageCell,
                  let seqNumber = cell.message?.seqNumber else { return }
            self.presenter?.loadMoreMessages(maxSeqNumber: seqNumber)
        })
    }
    
    fileprivate let navigationDivider: UIView = .init({
        $0.backgroundColor = .gray200
    })
    
    private lazy var tableView: UITableView = .init {[weak self] tableView in
        guard let `self` = self else { return }
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        tableView.registerCell(type: BaseMessageCell.self)
        tableView.registerCell(type: IncomeMessageCell.self)
        tableView.registerCell(type: IncomingPhotoCell.self)
        tableView.registerCell(type: IncomingVideoCell.self)
        tableView.registerCell(type: OutgoingMessageCell.self)
        tableView.registerCell(type: OutgoingPhotoCell.self)
        tableView.registerCell(type: OutgoingVideoCell.self)
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
    
    private lazy var headline: ProfileNavigationView = .init({[weak self] view in
        guard let `self` = self else { return }
        view.callback = {[weak self] in
            self?.presenter?.navigateToContact()
        }
    })
    
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
        self.tableView
            .rx
            .modelSelected(Message.self)
            .map({ [weak self] message in
                return self?.presenter?.mediaURL(from: message)
            })
            .compactMap({$0})
            .subscribe(onNext: { [weak self] url in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                self.mediaItem = url
                let previewController = QLPreviewController()
                previewController.dataSource = self
                previewController.currentPreviewItemIndex = 0
                self.present(previewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.tableView.rx
            .itemSelected
            .asDriver()
            .drive(onNext: {[weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    
        self.presenter?
            .messages
            .subscribe(on: MainScheduler.instance)
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
                    let cell: IncomingPhotoCell = tableView.dequeueCell()
                    cell.setup(message: message)
                    return cell
                } else if !message.isIncome && message.photo.fileID != "" {
                    let cell: OutgoingPhotoCell = tableView.dequeueCell()
                    cell.setup(message: message)
                    return cell
                } else if message.isIncome && message.video.fileID != "" {
                    let cell: IncomingVideoCell = tableView.dequeueCell()
                    cell.setup(message: message)
                    return cell
                } else if !message.isIncome && message.video.fileID != "" {
                    let cell: OutgoingVideoCell = tableView.dequeueCell()
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
            case .fromGallery: self.openMedia(type: .savedPhotosAlbum)
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
        let viewController = AdditioanalController()
        viewController.resultCallback = { [weak self] action in
            guard let `self` = self else { return }
            switch action {
            case .money_tranfer:
                self.openMoneyTransfer()
            }
        }
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = sheetTransitioningDelegate
        present(viewController, animated: true)
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
    
    func stopRefresh(removeController: Bool) {
        self.refreshControl.endRefreshing()
        if(removeController) {
            self.refreshControl.removeFromSuperview()
        }
    }
    func display(is typing: UserTypingWithDate) {
        self.headline.setup(user: typing)
    }
    
    func setup(conversation: Conversation) {
        self.headline.setup(conversation: conversation)
    }
}


private extension ConversationViewController {
    
    func openMoneyTransfer() {
        let viewController = MoneyTransferConroller()
        viewController.resultCallback = {[weak self] amount in
            guard let `self` = self else { return }
            self.presenter?.send(money: amount)
        }
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = moneyTransitioningDelegate
        self.present(viewController, animated: true)
    }
    
    func openMedia(type: UIImagePickerController.SourceType) {
        self.present(UIImagePickerController({
            $0.delegate = self
            $0.sourceType = type
            $0.videoQuality = .typeMedium
            $0.mediaTypes = ["public.movie", "public.image"]
            $0.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        }), animated: true)
    }
}


extension ConversationViewController {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info["UIImagePickerControllerMediaType"] as? String == "public.movie",
            let url = info["UIImagePickerControllerMediaURL"]  as? URL,
            let data = try? Data(contentsOf: url) {
            picker.dismiss(animated: true)
            self.presenter?.upload(file: .init(url: url, data: data, mime: "video/mp4", width: 300, height: 200))
        } else if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage,
                  let downsampled = image.downsample(reductionAmount: 0.7),
                  let data = downsampled.pngData() {
            picker.dismiss(animated: true, completion: {
                
                self.presenter?.upload(file: .init(url: nil, data: data, mime: "image/png", width: image.size.width, height: image.size.height))
            })
        }
    }
}

extension ConversationViewController: QLPreviewControllerDataSource  {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let item = mediaItem else {
            fatalError(NSError.objectsIsNill.localizedDescription)
        }
        return item as QLPreviewItem
    }
}
