//
//  SheetView+Extension.swift
//  UltraCore
//
//  Created by Typi on 17.04.2024.
//

import Foundation
import FittedSheets
import UIKit

extension SheetViewController {
    convenience init(contentController: UIViewController) {
        let options = SheetOptions(shrinkPresentingViewController: false)
        self.init(controller: contentController, sizes: [.intrinsic], options: options)
        allowPullingPastMaxHeight = false
    }
}
