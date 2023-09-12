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
import ContactsUI

final class ConversationViewController: BaseViewController<ConversationPresenterInterface> {
    // MARK: - Properties
    
    let sheetTransitioningDelegate = SheetTransitioningDelegate()
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
        $0.backgroundColor = UltraCoreStyle.divederColor.color
    })
    
    private lazy var tableView: UITableView = .init {[weak self] tableView in
        guard let `self` = self else { return }
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        tableView.registerCell(type: IncomeFileCell.self)
        tableView.registerCell(type: OutcomeFileCell.self)
        tableView.registerCell(type: BaseMessageCell.self)
        tableView.registerCell(type: IncomeVoiceCell.self)
        tableView.registerCell(type: OutcomeVoiceCell.self)
        tableView.registerCell(type: IncomeMoneyCell.self)
        tableView.registerCell(type: OutcomeMoneyCell.self)
        tableView.registerCell(type: IncomeMessageCell.self)
        tableView.registerCell(type: IncomingPhotoCell.self)
        tableView.registerCell(type: IncomingVideoCell.self)
        tableView.registerCell(type: OutgoingPhotoCell.self)
        tableView.registerCell(type: IncomeContactCell.self)
        tableView.registerCell(type: OutgoingVideoCell.self)
        tableView.registerCell(type: OutcomeContactCell.self)
        tableView.registerCell(type: IncomeLocationCell.self)
        tableView.registerCell(type: OutcomeLocationCell.self)
        tableView.registerCell(type: OutgoingMessageCell.self)
        tableView.contentInset = .init(top: kMediumPadding, left: 0, bottom: 0, right: 0)
        tableView.backgroundView = UIImageView({
            $0.contentMode = .scaleAspectFill
            $0.image = .named("conversation_background")
        })
    }
    
    fileprivate lazy var messageHeadline: SubHeadline = .init({
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
    
    private lazy var editInputBar: EditActionBottomBar = .init({ [weak self] inputBar in
        inputBar.delegate = self
    })
    
    private lazy var voiceInputBar: VoiceInputBar = .init({ [weak self] inputBar in
        inputBar.delegate = self
    })
    
    // MARK: - Private Methods
    
    override func setupViews() {
        self.handleKeyboardTransmission = true
        super.setupViews()
        self.navigationItem.rightBarButtonItems = [.init(image: .named("conversation_video_camera_icon"),
                                                         style: .done, target: self, action: #selector(self.callWithVideo(_:))),
                                                   .init(image: .named("conversation_phone_icon"),
                                                         style: .done, target: self, action: #selector(self.callWithVoice(_:)))]
        self.view.addSubview(tableView)
        self.view.addSubview(messageHeadline)
        self.view.addSubview(messageInputBar)
        self.view.addSubview(navigationDivider)
        self.view.addSubview(editInputBar)
        self.view.addSubview(voiceInputBar)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = .init(customView: headline)
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
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .do(onNext: {[weak self] messages in
                self?.messageHeadline.text = messages.isEmpty ? ConversationStrings.thereAreNoMessagesInThisChat.localized : ""
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
            .bind(to: tableView.rx.items) { [weak self] tableView, indexPath,
                message in
                guard let `self` = self else {
                    return UITableViewCell.init()
                }
                let cell = self.cell(message, in: tableView)
                cell.longTapCallback = {[weak self] message in
                    guard let `self` = self else { return }
                    self.presentEditController(for: message, indexPath: IndexPath(row: indexPath, section: 0))
                }
                
                cell.actionCallback = {[weak self] message in
                    
                    
                    guard let `self` = self,
                          let content = message.content else { return }
                    
                    switch content {
                    case .location(let location):
                        if let url = URL(string: "maps://?q=\(location.lat),\(location.lon)"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    default:
                        guard let url = self.presenter?.mediaURL(from: message) else { return }
                        self.view.endEditing(true)
                        self.mediaItem = url
                        let previewController = QLPreviewController()
                        previewController.modalPresentationStyle = .formSheet
                        previewController.dataSource = self
                        previewController.currentPreviewItemIndex = 0
                        self.present(previewController, animated: true)
                    }
                }
                return cell
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let cell = self.tableView.visibleCells.first as? BaseMessageCell,
              let seqNumber = cell.message?.seqNumber else { return }
        self.presenter?.loadMoreMessages(maxSeqNumber: seqNumber)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.navigationDivider.backgroundColor = UltraCoreStyle.divederColor.color
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
            case .document: self.openDocument()
            case .contact: self.openContact()
            case .location: self.openMap()
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
        self.view.addSubview(voiceInputBar)
        self.voiceInputBar.snp.makeConstraints({make in
            make.edges.equalTo(self.messageInputBar)
        })
        self.voiceInputBar.setActiveRecord()
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
        self.presenter?.openMoneyController()
    }
    
    func openMedia(type: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = type
        controller.videoQuality = .typeMedium
        controller.mediaTypes = ["public.movie", "public.image"]
        controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        self.present(controller, animated: true)
    }
    
    func openDocument() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func openContact() {
        let contactPickerVC = CNContactPickerViewController()
        contactPickerVC.delegate = self
        self.present(contactPickerVC, animated: true)
    }

    func openMap() {
        let mapController = MapController()
        mapController.locationCallback = { [weak self] message in
            guard let `self` = self else { return }
            self.presenter?.send(location: message)
        }
        self.present(mapController, animated: true)
    }
}


extension ConversationViewController: (UIImagePickerControllerDelegate & UINavigationControllerDelegate){
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[UIImagePickerController.InfoKey.mediaType] as? String == "public.movie",
           let url = info[.mediaURL]  as? URL,
            let data = try? Data(contentsOf: url) {
            picker.dismiss(animated: true)
            self.presenter?.upload(file: .init(url: url, data: data, mime: "video/mp4", width: 300, height: 200))
        } else if let image = info[.originalImage] as? UIImage,
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

extension ConversationViewController {
    @objc func callWithVideo(_ sender: UIBarButtonItem) {
        self.presenter?.callVideo()
    }
    
    @objc func callWithVoice(_ sender: UIBarButtonItem) {
        self.presenter?.callVoice()
    }
    
    func cell(_ message: Message, in tableView: UITableView) -> BaseMessageCell {
        
        guard let content = message.content else {
            if message.isIncome {
                let cell: IncomeMessageCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            } else {
                let cell: OutgoingMessageCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            }
        }
        
        switch content {
        case  .photo:
            if message.isIncome {
                let cell: IncomingPhotoCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            } else {
                let cell: OutgoingPhotoCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            }
        case .video:
            if message.isIncome {
                let cell: IncomingVideoCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            } else {
                let cell: OutgoingVideoCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            }
        case .money:

            if message.isIncome {
                let cell: IncomeMoneyCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell

            } else {
                let cell: OutcomeMoneyCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            }
            
        case .file:
            if message.isIncome {
                let cell: IncomeFileCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            } else {
                let cell: OutcomeFileCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            }
        case .contact:
            if message.isIncome {
                let cell: IncomeContactCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            } else {
                let cell: OutcomeContactCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            }
        case .location:
            if message.isIncome {
                let cell: IncomeLocationCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            } else {
                let cell: OutcomeLocationCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            }
        case .voice:
            if message.isIncome {
                let cell: IncomeVoiceCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            } else {
                let cell: OutcomeVoiceCell = tableView.dequeueCell()
                cell.setup(message: message)
                return cell
            }
        case .audio(_):
            let cell: BaseMessageCell = tableView.dequeueCell()
            cell.setup(message: message)
            return cell
        }
    }
    
    func presentEditController(for message: Message, indexPath: IndexPath) {
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.setEditing(!tableView.isEditing, animated: true)
        
        if(tableView.isEditing) {
            self.view.addSubview(editInputBar)
            editInputBar.snp.makeConstraints({make in
                make.edges.equalTo(self.messageInputBar)
            })
        } else {
            self.editInputBar.removeFromSuperview()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.tableView.reloadData()
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        })
    }
}

extension ConversationViewController: EditActionBottomBarDelegate {
    func cancel() {
        self.editInputBar.removeFromSuperview()
        self.tableView.setEditing(false, animated: true)
    }
    
    func delete() {
        
        let messages = self.tableView.indexPathsForSelectedRows?
            .map { indexPath in self.tableView.cellForRow(at: indexPath) }
            .compactMap({ $0 as? BaseMessageCell })
            .map({ $0.message })
            .compactMap({ $0 }) ?? []
        
        guard !messages.isEmpty else { return }
        
        let alert = UIAlertController(title: "Вы уверены?", message: "Пожалуйста, обратите внимание, что данные сообщения будут безвозвратно удалены, и восстановление не будет возможным", preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Удалить для всех", style: .destructive, handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.presenter?.delete(messages, all: true)
            self.cancel()
        }))
        alert.addAction(.init(title: "Удалить у меня", style: .destructive, handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.presenter?.delete(messages, all: false)
            self.cancel()
        }))
        alert.addAction(.init(title: "Отмена", style: .cancel))
        self.present(alert, animated: true)
    }
}

extension ConversationViewController: UIDocumentPickerDelegate {
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first,
                  let data = try? Data(contentsOf: selectedURL) else {
                return
            }

            self.presenter?.upload(file: .init(url: selectedURL, data: data, mime: selectedURL.mimeType().containsAudio ? "audio/mp3" : selectedURL.mimeType(), width: 300, height: 300))
        }
        
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { }
}

extension ConversationViewController: VoiceInputBarDelegate {
    func recordedVoice(url: URL, in duration: TimeInterval) {
        guard duration > 2,
              let data = try? Data(contentsOf: url) else { return }
        self.presenter?.upload(file: FileUpload(url: nil, data: data, mime: "audio/wav", width: 0, height: 0, duration: duration))
    }
}

extension ConversationViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        for phoneNumber in contact.phoneNumbers {
            let phoneNumberValue = phoneNumber.value
            let number = phoneNumberValue.stringValue
            self.presenter?.send(contact: .with {
                $0.firstname = contact.givenName
                $0.lastname = contact.familyName
                $0.phone = number
            })
        }
    }
}
