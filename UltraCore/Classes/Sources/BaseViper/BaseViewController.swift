//
//  BaseViewController.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit
import RxSwift

let kHeadlinePadding: CGFloat = 24
let kMediumPadding: CGFloat = 16
let kLowPadding: CGFloat = 8

class BaseViewController<T>: UIViewController {
    var presenter: T?
    var isDebugMode: Bool = true
    let disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupConstraints()
        self.setupInitialData()
        
        if isDebugMode { self.debugInitialData() }
    }
    
    deinit {
        Logger.info("Deinit \(String.init(describing: self))")
    }
}


extension UIViewController {
    
    
    @objc func debugInitialData() {
        
    }
    @objc func setupViews() {
        self.view.backgroundColor = .gray100
    }
    @objc func setupConstraints() {}
    @objc func setupInitialData() {}
}
