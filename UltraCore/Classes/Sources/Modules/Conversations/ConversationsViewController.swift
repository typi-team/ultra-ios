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

    fileprivate lazy var permissionData = PermissionStateViewData(imageName: "conversations_centered_card",
                                                                  headline: "Нет сообщений",
                                                                  subline: "У вас пока нет сообщений. Начните общаться с вашими контактами прямо сейчас.")
    fileprivate lazy var backgroundView: PermissionStateView = .init(data: permissionData)
    
    fileprivate lazy var tableView: UITableView = {
        if #available(iOS 13.0, *) {
            return .init(frame: .zero, style: .insetGrouped)
        } else {
            return .init()
        }
    }()
    
    override func setupViews() {
        super.setupViews()
        self.view.addSubview(tableView)
        self.tableView.rowHeight = 64
        self.tableView.sectionHeaderHeight = 0
        self.tableView.registerCell(type: ConversationCell.self)
        self.tableView.backgroundColor = self.view.backgroundColor
        self.tableView.separatorInset = .init(top: 0, left: kMediumPadding * 2, bottom: 0, right: kMediumPadding)
        self.navigationItem.rightBarButtonItem = .init(image: .named("conversation_new_icon"),
                                                       style: .plain, target: self,
                                                       action: #selector(self.openContacts))
        
        self.navigationItem.title = "Список чатов"
        self.hidesBottomBarWhenPushed = false
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupInitialData() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {[weak self] in
            self?.presenter?.retrieveContactStatuses()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.presenter?.setupUpdateSubscription()
        self.presenter?.conversation
            .observe(on: MainScheduler.instance)
            .do(onNext: {[weak self] conversations in
                guard let `self` = self else { return }
                if conversations.isEmpty {
                    self.tableView.backgroundView = backgroundView
                } else {
                    self.tableView.backgroundView = nil
                }
            })
            .bind(to: tableView.rx.items) { tableView, index, model in
                let cell: ConversationCell = tableView.dequeueCell()
                cell.setup(conversation: model)
                return cell
            }
            .disposed(by: self.disposeBag)
        
        self.tableView
            .rx.itemSelected
            .subscribe { [weak self] (index: IndexPath) in
                guard let `self` = self else { return }
                self.tableView.deselectRow(at: index, animated: true)
            }
            .disposed(by: disposeBag)
        
        self.tableView.rx
            .modelSelected(Conversation.self)
            .subscribe { [weak self](conversation: Conversation) in
                guard let `self` = self else { return }
                self.presenter?.navigate(to: conversation)
            }
            .disposed(by: disposeBag)
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
    
    @objc func willEnterForeground(_ sender: Any) {
        self.presenter?.updateStatus(is: true)
        self.presenter?.retrieveContactStatuses()
    }
    
    @objc func didEnterBackground(_ sender: Any) {
        self.presenter?.updateStatus(is: false)
    }
}
