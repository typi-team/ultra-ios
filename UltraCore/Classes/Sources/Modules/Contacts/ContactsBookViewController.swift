//
//  ContactsBookViewController.swift
//  Pods
//
//  Created by Slam on 4/21/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxDataSources

final class ContactsBookViewController: BaseViewController<ContactsBookPresenterInterface> {

    // MARK: - Public properties -
    
    fileprivate let tableView: UITableView = {
        if #available(iOS 13.0, *) {
            return .init(frame: .zero, style: .insetGrouped)
        } else {
            return .init()
        }
    }()
    
    // MARK: - Lifecycle -
    
    override func setupViews() {
        super.setupViews()
        self.navigationItem.title = "Новый чат"
        self.navigationItem.rightBarButtonItem = .init(image: .named("icon_close"), style: .plain, target: self, action: #selector(close(_:)))
        
        self.view.addSubview(tableView)
        
        self.tableView.rowHeight = 50
        self.tableView.separatorStyle = .singleLine
        self.tableView.registerCell(type: ContactCell.self)
        self.tableView.separatorInset = .init(top: 0, left: 32, bottom: 0, right: 16)
        
        self.presenter?
            .contacts
            .do(onNext: {[weak self] contacts in
                guard let `self` = self else { return }
                if contacts.isEmpty {
                    self.contacts(is: contacts.isEmpty)
                } else if !AppHardwareUtils.checkPermissons() {
                    self.permission(is: false)
                }
                
            })
            .bind(to: tableView.rx.items) { tableView, _, contact in
                let cell: ContactCell = tableView.dequeueCell()
                cell.setup(contact: contact)
                return cell
            }
            .disposed(by: disposeBag)
        
        self.tableView
            .rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] index in
                guard let `self` = self else { return }
                self.tableView.deselectRow(at: index, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.tableView.rx
            .modelSelected(ContactDisplayable.self)
            .asDriver()
            .drive { [weak self ] contact in
                guard let `self` = self else { return }
                self.presenter?.openConversation(with: contact)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupInitialData() {
        self.presenter?.initial()
    }
}

// MARK: - Extensions -

extension ContactsBookViewController: ContactsBookViewInterface {
    func contacts(is empty: Bool) {
        if empty {
            let data = PermissionStateViewData(imageName: "contacts_centered_card",
                                               headline: "Ваш список контактов пуст",
                                               subline: "К сожалению у вас нет контактов которые используют данное приложение.")
            self.tableView.backgroundView = PermissionStateView(data: data)
        } else {
            self.tableView.backgroundView = nil
        }
    }
    
    func permission(is denied: Bool) {
        if denied {
            self.tableView.backgroundView = PermissionStateView(data: PermissionStateViewData(imageName: "contacts_centered_card",
                                                                                              headline: "Нет доступа к контактам",
                                                                                              subline: "Нажмите на кнопку ниже и предоставьте доступ к вашим контактам.",
                                                                                              action: {
                                                                                                  UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                                                                                              })
            )
        } else {
            self.tableView.backgroundView = nil
        }
    }
}
