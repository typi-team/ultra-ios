//
//  ConversationsViewController.swift
//  Pods
//
//  Created by Slam on 4/20/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ConversationsViewController: BaseViewController<ConversationsPresenterInterface> {

    fileprivate lazy var permissionData = PermissionStateViewData(imageName: "conversations_empty",
                                                                  headline: ConversationsStrings.emptyMessages.localized,
                                                                  subline: ConversationsStrings.startCommunicatingWithYourContactsNow.localized.localized,
                                                                  action: .init(title: ConversationsStrings.start.localized, callback: {[weak self] in self?.presenter?.navigateToContacts()}))
    fileprivate lazy var backgroundView: PermissionStateView = .init(data: permissionData)
    
    fileprivate lazy var tableView: UITableView = {
        if #available(iOS 13.0, *) {
            return .init(frame: .zero, style: .insetGrouped)
        } else {
            return .init()
        }
    }()
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Conversation>>(configureCell: {_, tableView, indexPath,
        model in
        
        let cell: ConversationCell = tableView.dequeueCell()
        cell.setup(conversation: model)
        return cell
    }, canEditRowAtIndexPath: { data, indexpath in
        if let phone = data.sectionModels[indexpath.section].items[indexpath.row].peer?.phone {
            return !phone.contains("+00000000000")
        } else {
            return true
        }
    })
    override func setupViews() {
        super.setupViews()
        
        self.view.addSubview(tableView)
        self.tableView.rowHeight = 64
        self.tableView.backgroundColor = nil
        self.tableView.sectionHeaderHeight = 0
        self.tableView.registerCell(type: ConversationCell.self)
        self.tableView.separatorInset = .init(top: 0, left: kMediumPadding * 2, bottom: 0, right: kMediumPadding)
        self.navigationItem.rightBarButtonItem = .init(image: .named("conversation_new_icon"),
                                                       style: .plain, target: self,
                                                       action: #selector(self.openContacts))
        
        self.navigationItem.title = ConversationsStrings.chats.localized
        self.hidesBottomBarWhenPushed = false
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupInitialData() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.presenter?.conversation
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .do(onNext: {[weak self] conversations in
                guard let `self` = self else { return }
                if conversations.isEmpty {
                    self.tableView.backgroundView = UltraCoreSettings.delegate?.emptyConversationView() ?? self.backgroundView
                } else {
                    self.tableView.backgroundView = nil
                }
            }).map({ conversation -> [SectionModel<String, Conversation>] in
                return [SectionModel<String, Conversation>.init(model: "", items: conversation)]
            })
                .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView
            .rx.itemSelected
            .subscribe { [weak self] (index: IndexPath) in
                guard let `self` = self else { return }
                self.tableView.deselectRow(at: index, animated: true)
            }
            .disposed(by: disposeBag)
        
        self.tableView
            .rx
            .modelDeleted(Conversation.self)
            .subscribe(onNext: {[weak self] conversation in
                guard let `self` = self else { return }
                let alert = UIAlertController.init(title: ConversationsStrings.areYouSure.localized, message: ConversationsStrings.pleaseNoteThatMessageDataWillBePermanentlyDeletedAndRecoveryWillNotBePossible.localized, preferredStyle: .actionSheet)
                alert.addAction(.init(title: ConversationsStrings.deleteFromMe.localized, style: .destructive, handler: { _ in
                    self.presenter?.delete(conversation, all: false)
                }))
                alert.addAction(.init(title: EditActionStrings.cancel.localized.capitalized, style: .cancel))
                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.tableView.rx
            .modelSelected(Conversation.self)
            .subscribe { [weak self](conversation: Conversation) in
                guard let `self` = self else { return }
                self.presenter?.navigate(to: conversation)
            }
            .disposed(by: disposeBag)
        
        presenter?.viewDidLoad()
    }
}

// MARK: - Extensions -

extension ConversationsViewController {
    @objc func openContacts(_ sender: Any) {
        self.presenter?.navigateToContacts()
    }
}

extension ConversationsViewController: ConversationsViewInterface {}
extension ConversationsViewController {
    @objc func didEnterBackground(_ sender: Any) {
        self.presenter?.stopPingPong()
    }

    @objc func didEnterForeground(_ sender: Any) {
        self.presenter?.startPingPong()
    }
}
