//
//  BaseViewController.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit

let kHeadlinePadding: CGFloat = 24
let kMediumPadding: CGFloat = 16
let kLowPadding: CGFloat = 8

class BaseViewController<T>: UIViewController {
    
    var presenter: T?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupConstraints()
        self.setupInitialData()
    }
    
    deinit {
        Logger.info("Deinit \(String.init(describing: self))")
    }
}


extension UIViewController {
    @objc func setupViews() {
        self.view.backgroundColor = .gray100
    }
    @objc func setupConstraints() {}
    @objc func setupInitialData() {}
}
