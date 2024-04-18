//
//  SheetView+Extension.swift
//  UltraCore
//
//  Created by Typi on 17.04.2024.
//

import Foundation
import UIKit

extension UltraSheetViewController {
    convenience init(contentController: UIViewController) {
        let options = UltraSheetOptions(shrinkPresentingViewController: false)
        self.init(controller: contentController, sizes: [.intrinsic], options: options)
        allowPullingPastMaxHeight = false
    }
}
