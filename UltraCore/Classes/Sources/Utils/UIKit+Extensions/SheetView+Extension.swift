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
        gripSize = .init(width: 81.0, height: 3.0)
        gripColor = UIColor.from(hex: "e5e7eb").withAlphaComponent(0.5)
        hasBlurBackground = true
        allowPullingPastMaxHeight = false
    }
}
