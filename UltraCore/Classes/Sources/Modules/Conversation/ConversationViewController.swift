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

final class ConversationViewController: BaseViewController<ConversationPresenterInterface> {
    // MARK: - Properties
    
    fileprivate var isDrawingTable: Bool = false
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = .init {[weak self] tableView in
        guard let `self` = self else { return }
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.registerCell(type: BaseMessageCell.self)
        tableView.registerCell(type: IncomeMessageCell.self)
        tableView.registerCell(type: OutgoingMessageCell.self)
        tableView.backgroundColor = self.view.backgroundColor
        tableView.backgroundView = UIImageView({
            $0.contentMode = .scaleAspectFill
            $0.image = .named("conversation_background")
        })
    }
    
    private lazy var headline: ProfileNavigationView = .init()
    private lazy var messageInputBar: MessageInputBar = .init({ [weak self] inputBar in
        inputBar.delegate = self
    })
    
    // MARK: - Private Methods
    
    override func setupViews() {
        self.handleKeyboardTransmission = true
        super.setupViews()
        view.addSubview(tableView)
        view.addSubview(messageInputBar)
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = .init(customView: self.headline)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(messageInputBar.snp.topMargin).offset(-10)
        }
        
        messageInputBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
        }
    }
    
    override func setupInitialData() {
        super.setupInitialData()
        
        self.presenter?
            .messages
            .do(onNext: { [weak self ] result in
                guard let `self` = self, !self.isDrawingTable else {
                    return
                }
                self.isDrawingTable = true
                let isEmpty = self.tableView.numberOfRows(inSection: 0) - 1 <= 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
                    if lastRowIndex < 0 { return }
                    let indexPath = IndexPath(row: lastRowIndex, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: !isEmpty)
                    self.isDrawingTable = false
                })
            })
            .bind(to: tableView.rx.items) { tableView, _, message in
                if message.isIncome {
                    let cell: IncomeMessageCell = tableView.dequeueCell()
                    cell.setup(message: message.toProto())
                    return cell
                }else {
                    let cell: OutgoingMessageCell = tableView.dequeueCell()
                    cell.setup(message: message.toProto())
                    return cell
                }
                
            }
            .disposed(by: disposeBag)
        
        self.presenter?.viewDidLoad()
    }
    
    override func changed(keyboard height: CGFloat) {
        messageInputBar.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-height)
            
        }
    }
}

    // MARK: - UITextViewDelegate

extension ConversationViewController: MessageInputBarDelegate {
    func exchanges() {

    }
    
    func micro(isActivated: Bool) {
        
    }
    
    func message(text: String) {
        self.presenter?.send(message: text)
    }
}

// MARK: - Extensions -

extension ConversationViewController: ConversationViewInterface {
    func setup(conversation: Conversation) {
        self.headline.setup(conversation: conversation)
    }
}
