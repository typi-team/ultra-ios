//
//  UITableView+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import UIKit

extension UITableView {
    
    func registerCell(type: UITableViewCell.Type, identifier: String? = nil) {
        register(type, forCellReuseIdentifier: type.identifier)
    }
    
    func dequeueCell<T: UITableViewCell>() -> T {
        return dequeueReusableCell(withIdentifier: T.identifier) as! T
    }
    
    func reloadData(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }

    func scrollToFirstCell() {
        if numberOfSections > 0 {
            if numberOfRows(inSection: 0) > 0 {
                scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

    func scrollToLastCell(animated: Bool) {
        if numberOfSections > 0 {
            let rows = numberOfRows(inSection: numberOfSections - 1)
            if rows > 0 {
                scrollToRow(at: IndexPath(row: rows - 1, section: numberOfSections - 1), at: .bottom, animated: animated)
            }
        }
    }

    func stopScrolling() {
        guard isDragging else {
            return
        }
        var offset = self.contentOffset
        offset.y -= 1.0
        setContentOffset(offset, animated: false)

        offset.y += 1.0
        setContentOffset(offset, animated: false)
    }

    func scrolledToBottom() -> Bool {
        return contentOffset.y >= (contentSize.height - bounds.size.height)
    }
}

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    
}
