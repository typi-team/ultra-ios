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

struct ContactSection {
    var header: String
    var items: [Contact]
}

extension ContactSection: SectionModelType {
    typealias Item = Contact

    init(original: ContactSection, items: [Contact]) {
        self = original
        self.items = items
    }
}

final class ContactsBookViewController: BaseViewController<ContactsBookPresenterInterface> {

    // MARK: - Public properties -
    
    fileprivate let tableView: UITableView = {
        if #available(iOS 13.0, *) {
            return .init(frame: .zero, style: .insetGrouped)
        } else {
            return .init()
        }
    }()
    
    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<ContactSection>(
        configureCell: { dataSource, tableView, indexPath, item in
            let cell: ContactCell = tableView.dequeueCell()
            cell.setup(contact: item)
            return cell
        }, titleForHeaderInSection: { data, index in data[index].header })

    // MARK: - Lifecycle -
    
    override func setupViews() {
        super.setupViews()
        self.navigationItem.title = ContactsStrings.newChat.localized
        self.navigationItem.rightBarButtonItem = .init(image: .named("icon_close"), style: .plain, target: self, action: #selector(close(_:)))
        
        self.view.addSubview(tableView)
        
        self.tableView.rowHeight = 50
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .singleLine
        self.tableView.registerCell(type: ContactCell.self)
        self.tableView.separatorInset = .init(top: 0, left: 32, bottom: 0, right: 16)
        
        self.presenter?
            .contacts
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] contacts in
                guard let `self` = self else { return }
                if contacts.isEmpty && !AppHardwareUtils.checkPermissons() {
                    self.permission(is: true)
                } else if contacts.isEmpty && AppHardwareUtils.checkPermissons() {
                    self.contacts(is: true)
                } else if !AppHardwareUtils.checkPermissons() {
                    self.showSettingAlert(from: "Зайдите в настройки и переведите Контакты в состояние ВКЛ",
                                          with: "Freedom Chat не имеет доступа к вашим контактам")
                } else {
                    self.tableView.backgroundView = nil
                }
            })
            .map({ contacts in
                return Dictionary(grouping: contacts){ String($0.displaName.prefix(1)).uppercased()}
                    .map { key, value in
                        return ContactSection(header: key, items: value.sorted(by: { $0.displaName < $1.displaName }))
                    }.sorted(by: { $0.header < $1.header })
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
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
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                                                                                              })
            )
        } else {
            self.tableView.backgroundView = nil
        }
    }
}
