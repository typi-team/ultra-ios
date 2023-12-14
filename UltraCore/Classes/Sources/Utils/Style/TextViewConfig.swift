//
//  TextViewConfig.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol TextViewConfig: LabelConfig {
    var tintColor: TwiceColor { get set }
    var placeholder: String { get set }
}
