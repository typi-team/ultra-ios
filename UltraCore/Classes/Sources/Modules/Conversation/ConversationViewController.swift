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
import AVFoundation
import RxCocoa
import RxSwift
import QuickLook
import ContactsUI
import RxDataSources
import AVFoundation

final class ConversationViewController: BaseViewController<ConversationPresenterInterface> {
    // MARK: - Properties
    
    let reportTransitioningDelegate = SheetTransitioningDelegate()
    let sheetTransitioningDelegate = SheetTransitioningDelegate()
    fileprivate var mediaItem: URL?
    fileprivate var isDrawingTable: Bool = false
    lazy var dismissKeyboardGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
    
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
        $0.backgroundColor = UltraCoreStyle.divederColor?.color
    })
    
    private lazy var tableView: UITableView = .init {[weak self] tableView in
        guard let `self` = self else { return }
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        tableView.delegate = self
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
        tableView.addGestureRecognizer(dismissKeyboardGesture)
        tableView.contentInset = .zero
    }
    
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
    private var messages: [Message] = []
    
    private lazy var backgroundImageView: UIImageView = .init { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.image = UltraCoreStyle.conversationBackgroundImage?.image
    }

   private lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Message>>(
        configureCell: { [weak self] _, tableView, indexPath,
            message in
            guard let `self` = self else {
                return UITableViewCell.init()
            }
            let cell = self.cell(message, in: tableView)
            cell.longTapCallback = {[weak self] actionType in
                guard let `self` = self else { return }
                switch actionType {
                case let .select(message):
                    self.presentEditController(for: message, indexPath: indexPath)
                case let .delete(message):
                    self.presentDeletedMessageView(messages: [message])
                case .reply:
                    break
                case let .copy(message):
                    UIPasteboard.general.string = message.text
                case .reportDefined(message: let message, type: let type):
                    self.presentReportMessageView(message, with: type)
                }
            }
            
            cell.cellActionCallback = {[weak self] () in
                if let self = self,
                    self.messageInputBar.isRecording {return}
                self?.view.endEditing(true)
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
                case .voice:
                    break
                default:
                    guard let url = self.presenter?.mediaURL(from: message) else { return }
                    self.view.endEditing(true)
                    self.mediaItem = url
                    let previewController = QLPreviewController()
                    previewController.modalPresentationStyle = .formSheet
                    previewController.dataSource = self
                    previewController.currentPreviewItemIndex = 0
                    self.navigationController?.pushViewController(previewController, animated: true)
                }
            }
            return cell
        }, titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }, canMoveRowAtIndexPath: { _, _  in
            return false
        }
    )
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    override func setupViews() {
        self.handleKeyboardTransmission = true
        super.setupViews()
//        MARK: Must be hide
        self.setupNavigationMore()
        self.view.addSubview(tableView)
        self.view.addSubview(messageInputBar)
        self.view.addSubview(navigationDivider)
        self.view.addSubview(editInputBar)
        self.view.addSubview(voiceInputBar)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = .init(customView: headline)
    }
    override func setupStyle() {
        super.setupStyle()
        self.tableView.backgroundView = backgroundImageView
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
            make.bottom.equalTo(view.snp.bottom)
        }
        
        self.messageInputBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    override func setupInitialData() {
        super.setupInitialData()
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.presenter?
            .messages
            .distinctUntilChanged()
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .do(onNext: {[weak self] messages in
                self?.messages = messages
                self?.tableView.backgroundView = messages.isEmpty ? ConversationEmptyViewContainer(emptyView: UltraCoreSettings.delegate?.emptyConversationDetailView() ?? .init()) : self?.backgroundImageView
            })
            .map({messages -> [SectionModel<String, Message>] in
                if messages.isEmpty {return []}
                return Dictionary(grouping: messages) { message in
                    return Calendar.current.startOfDay(for: message.meta.created.date)}
                    .sorted { $0.key < $1.key }
                    .map({SectionModel<String, Message>.init(model: $0.key.formattedTimeToHeadline(format: "d MMMM yyyy"), items: $0.value)})
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
                
            var prev: [Message] = []
        self.presenter?
            .messages
            .debounce(.milliseconds(20), scheduler: MainScheduler.asyncInstance)
            .filter({ !$0.isEmpty })
            .filter({$0.count != prev.count})
            .do(onNext: {prev = $0})
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if self.tableView.isDecelerating {
                    self.tableView.stopScrolling()
                }
                self.tableView.scrollToLastCell(animated: false)
                
            })
            .disposed(by: disposeBag)
        
        self.presenter?.viewDidLoad()
        subscribeToInputBoundsChange()
    }
    
    override func changedKeyboard(
        frame: CGRect,
        animationDuration: Double,
        animationOptions: UIView.AnimationOptions
    ) {
        var contentOffset = tableView.contentOffset
        
        let keyBoardHeight = UIScreen.main.bounds.height - frame.origin.y
        let bottomInset = keyBoardHeight > 0 ? keyBoardHeight - view.safeAreaInsets.bottom : 0
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
        
        if let backgroundView = tableView.backgroundView as? ConversationEmptyViewContainer {
            backgroundView.setSubviewOffset(
                y: keyBoardHeight == 0 ? 0 : -keyBoardHeight
            )
        }
        
        if tableView.contentSize.height > tableView.frame.height {
            if keyBoardHeight > 0 {
                contentOffset.y += (keyBoardHeight - self.view.safeAreaInsets.bottom)
            } else {
                contentOffset.y -= (frame.height - self.view.safeAreaInsets.bottom)
            }
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
                self.tableView.contentOffset = contentOffset
            }
        }
        
        messageInputBar.snp.updateConstraints { make in
            if keyBoardHeight == 0 {
                make.bottom.equalTo(view.snp.bottom)
            } else {
                make.bottom.equalTo(view.snp.bottom).offset(-(keyBoardHeight - view.safeAreaInsets.bottom))
            }
        }
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.messageInputBar.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let cell = self.tableView.visibleCells.first as? BaseMessageCell,
              let seqNumber = cell.message?.seqNumber else { return }
        self.presenter?.loadMoreMessages(maxSeqNumber: seqNumber)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.navigationDivider.backgroundColor = UltraCoreStyle.divederColor?.color
    }
    
    private func subscribeToInputBoundsChange() {
        messageInputBar
            .rx
            .observe(\.bounds)
            .map(\.height)
            .subscribe(onNext: { [weak self] height in
                guard let self = self else { return }
                let bottomInset = height
                self.tableView.snp.updateConstraints({ make in
                    make.bottom.equalTo(self.view.snp.bottom).offset(-bottomInset)
                })
            })
            .disposed(by: disposeBag)
    }
    
    @objc func didEnterBackground(_ sender: Any) {
        messageInputBar.endEditing(true)
    }
    
}

    // MARK: - UITextViewDelegate

extension ConversationViewController: MessageInputBarDelegate {
    func unblock() {
        self.presenter?.block()
    }
    
    func pressedPlus(in view: MessageInputBar) {
        view.endEditing(true)
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
        presenter?.didTapTransfer()
//        let viewController = AdditioanalController()
//        viewController.resultCallback = { [weak self] action in
//            guard let `self` = self else { return }
//            switch action {
//            case .money_tranfer:
//                self.openMoneyTransfer()
//            }
//        }
//        viewController.modalPresentationStyle = .custom
//        viewController.transitioningDelegate = sheetTransitioningDelegate
//        present(viewController, animated: true)
    }
    
    func message(text: String) {
        self.presenter?.send(message: text)
    }
}

// MARK: - Extensions -

extension ConversationViewController: ConversationViewInterface {
    func blocked(is blocked: Bool) {
        if blocked {
            self.view.endEditing(true)
        }
        self.messageInputBar.block(blocked)
    }
    
    func reported() {
        self.showAlert(from: ConversationStrings.yourComplaintWillBeReviewedByModeratorsThankYou.localized)
    }
    
    
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
    
    func update(callAllowed: Bool) {
        let items: [UIBarButtonItem]
        if callAllowed && UltraCoreSettings.futureDelegate?.availableToCall() ?? false {
            items = [
                .init(
                    image: .named("conversation.dots"),
                    style: .plain,
                    target: self,
                    action: #selector(self.more(_:))
                ),
                .init(
                    image: .named("conversation_video_camera_icon"),
                    style: .plain,
                    target: self,
                    action: #selector(self.callWithVideo)
                ),
                .init(
                    image: .named("contact_phone_icon"),
                    style: .plain,
                    target: self,
                    action: #selector(self.callWithVoice)
                )
            ]
        } else {
            items = [
                .init(
                    image: .named("conversation.dots"),
                    style: .plain,
                    target: self,
                    action: #selector(self.more(_:))
                )
            ]
        }
        let mustBeHidden = UltraCoreSettings.futureDelegate?.availableToBlock(conversation: self) ?? false
        navigationItem.rightBarButtonItems = mustBeHidden ? items : nil
    }
    
    func showDisclaimer(show: Bool, delegate: DisclaimerViewDelegate) {
        show ? DisclaimerView.show(on: view, delegate: delegate) : DisclaimerView.hide(from: view)
        messageInputBar.isHidden = show
    }
    
    func showOnReceiveDisclaimer(delegate: DisclaimerViewDelegate, contact: ContactDisplayable?) {
        OnReceiveDisclaimerView.show(on: view, contact: contact, delegate: delegate)
        messageInputBar.isHidden = true
    }
}


private extension ConversationViewController {
    
    func setupNavigationMore() {
        let mustBeHide = UltraCoreSettings.futureDelegate?.availableToBlock(conversation: self) ?? false
        var items: [UIBarButtonItem] = [
            .init(
                image: .named("conversation.dots"),
                style: .plain,
                target: self,
                action: #selector(self.more(_:))
            )
        ]
        if presenter?.allowedToCall() ?? false && UltraCoreSettings.futureDelegate?.availableToCall() ?? false {
            let callItems: [UIBarButtonItem] = [
                .init(
                    image: .named("conversation_video_camera_icon"),
                    style: .plain,
                    target: self,
                    action: #selector(self.callWithVideo)
                ),
                .init(
                    image: .named("contact_phone_icon"),
                    style: .plain,
                    target: self,
                    action: #selector(self.callWithVoice)
                )
            ]
            items.append(contentsOf: callItems)
        }
        self.navigationItem.rightBarButtonItems = mustBeHide ? items : nil
    }
    
    func openMoneyTransfer() {
        self.presenter?.openMoneyController()
    }
    
    func openMedia(type: UIImagePickerController.SourceType) {
        if type == .savedPhotosAlbum {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = type
            controller.videoQuality = .typeMedium
            controller.mediaTypes = ["public.movie", "public.image"]
            controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
            self.present(controller, animated: true)
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            showSettingAlert(from: ConversationStrings.givePermissionToCamera.localized, with: BaseStrings.error.localized)
        case .restricted:
            showAlert(from: ConversationStrings.cameraPermissionRestricted.localized)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { isAuthorized in
                guard isAuthorized else {
                    return
                }
                DispatchQueue.main.async {
                    let controller = UIImagePickerController()
                    controller.delegate = self
                    controller.sourceType = type
                    controller.videoQuality = .typeMedium
                    controller.mediaTypes = ["public.movie", "public.image"]
                    controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
                    self.present(controller, animated: true)
                }
            }
        case .authorized:
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = type
            controller.videoQuality = .typeMedium
            controller.mediaTypes = ["public.movie", "public.image"]
            controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
            self.present(controller, animated: true)
        default:
            break
        }

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
            self.presenter?.upload(file: .init(url: url, data: data, mime: "video/mp4", width: 300, height: 200), isVoice: false)
        } else if let image = info[.originalImage] as? UIImage,
                  let downsampled = image.fixedOrientation().downsample(reductionAmount: 0.5),
                  let data = downsampled.pngData() {
            picker.dismiss(animated: true, completion: {
                self.presenter?.upload(file: .init(url: nil, data: data, mime: "image/png", width: image.size.width, height: image.size.height), isVoice: false)
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
    
    @objc func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func callWithVideo(_ sender: UIBarButtonItem) {
        checkVideoPermission { [weak self] in
            self?.presenter?.callVideo()
        }
    }
    
    @objc func callWithVoice(_ sender: UIBarButtonItem) {
        checkMicrophonePermission { [weak self] in
            self?.presenter?.callVoice()
        }
    }
    
    private func checkMicrophonePermission(onCompletion: @escaping () -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            onCompletion()
        case .denied:
            showSettingAlert(from: CallStrings.errorAccessToMicrophone.localized, with: CallStrings.errorAccessTitle.localized)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        onCompletion()
                    }
                }
            }
        default: break
        }
    }
    
    private func checkVideoPermission(onCompletion: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            onCompletion()
        case .denied, .restricted:
            showSettingAlert(from: CallStrings.errorAccessToCamera.localized, with: CallStrings.errorAccessTitle.localized)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        onCompletion()
                    }
                }
            }
        default: break
        }
    }
    
    @objc func more(_ sender: UIBarButtonItem) {
        guard let blocked = self.presenter?.isBlock() else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if blocked {
            alert.addAction(.init(title: ConversationStrings.unblock.localized.capitalized, style: .default, handler: { [weak self] _ in
                guard let `self` = self else { return }
                self.presenter?.block()
            }))
        } else {
            alert.addAction(.init(title: ConversationStrings.block.localized.capitalized, style: .destructive, handler: { [weak self] _ in
                guard let `self` = self else { return }
                self.presenter?.block()
            }))
        }

        alert.addAction(.init(title: EditActionStrings.cancel.localized.capitalized, style: .cancel))
        self.present(alert, animated: true)
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
        case .stock(_):
            let cell: BaseMessageCell = tableView.dequeueCell()
             return cell
        case .coin(_):
            let cell: BaseMessageCell = tableView.dequeueCell()
             return cell
        }
    }
    
    func presentEditController(for message: Message, indexPath: IndexPath) {
        dismissKeyboardGesture.isEnabled = false
        navigationItem.rightBarButtonItem = .init(image: .named("icon_close"), style: .done, target: self, action: #selector(self.cancel))
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if(tableView.isEditing) {
            view.addSubview(editInputBar)
            editInputBar.snp.makeConstraints({make in
                make.edges.equalTo(self.messageInputBar)
            })
        } else {
            editInputBar.removeFromSuperview()
        }
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
}

extension ConversationViewController: EditActionBottomBarDelegate {
    func share() {
        self.showInProgressAlert()
    }
    
    func reply() {
        self.showInProgressAlert()
    }
    
    func presentReportMessageView(_ message: Message, with type: ComplainTypeEnum) {
        let viewController = ReportCommentController({ controler in
            controler.saveAction = {[weak self] comment in
                guard let `self` = self else { return }
                controler.dismiss(animated: true)
                self.presenter?.report(message, with: type, comment: comment)
                self.cancel()
            }
        })
        
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = reportTransitioningDelegate
        present(viewController, animated: true)
    }
    
    @objc func cancel() {
        dismissKeyboardGesture.isEnabled = true
        editInputBar.removeFromSuperview()
        tableView.setEditing(false, animated: true)
        tableView.beginUpdates()
        tableView.endUpdates()
        setupNavigationMore()
    }
    
    func delete() {
        
        let messages = self.tableView.indexPathsForSelectedRows?
            .map { indexPath in self.tableView.cellForRow(at: indexPath) }
            .compactMap({ $0 as? BaseMessageCell })
            .map({ $0.message })
            .compactMap({ $0 }) ?? []
        
        guard !messages.isEmpty else { return }
        self.presentDeletedMessageView(messages: messages)
    }
    
    func presentDeletedMessageView(messages: [Message]) {
        let alert = UIAlertController(title: ConversationStrings.areYouSure.localized, message: ConversationStrings.pleaseNoteThatMessageDataWillBePermanentlyDeletedAndRecoveryWillNotBePossible.localized, preferredStyle: .actionSheet)
        alert.addAction(.init(title: ConversationStrings.deleteFromMe.localized, style: .destructive, handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.presenter?.delete(messages, all: false)
            self.cancel()
        }))

        alert.addAction(.init(title: ConversationStrings.deleteForEveryone.localized, style: .destructive, handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.presenter?.delete(messages, all: true)
            self.cancel()
        }))

        alert.addAction(.init(title: EditActionStrings.cancel.localized.capitalized, style: .cancel))
        self.present(alert, animated: true)
    }
}

extension ConversationViewController: UIDocumentPickerDelegate {
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first,
                  let data = try? Data(contentsOf: selectedURL) else {
                return
            }

            self.presenter?.upload(file: .init(url: selectedURL, data: data, mime: selectedURL.mimeType().containsAudio ? "audio/mp3" : selectedURL.mimeType(), width: 300, height: 300), isVoice: false)
        }
        
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { }
}

extension ConversationViewController: VoiceInputBarDelegate {
    func showVoiceError() {
        showSettingAlert(from: ConversationStrings.givePermissionToRecordVoice.localized, with: BaseStrings.error.localized)
    }
    
    func recordedVoice(url: URL, in duration: TimeInterval) {
        guard duration > 2,
              let data = try? Data(contentsOf: url) else { return }
        self.presenter?.upload(file: FileUpload(url: nil, data: data, mime: "audio/wav", width: 0, height: 0, duration: duration), isVoice: true)
    }
}

extension ConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .zero
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeadlinePadding + kMediumPadding
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeadlineInSectionView {[weak self] view in
            view.setup(title: self?.dataSource.sectionModels[section].model ?? "")
        }
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
