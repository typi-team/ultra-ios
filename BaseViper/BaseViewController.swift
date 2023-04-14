//
//  BaseViewController.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit

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
    func setupViews() {}
    func setupConstraints() {}
    func setupInitialData() {}
}
