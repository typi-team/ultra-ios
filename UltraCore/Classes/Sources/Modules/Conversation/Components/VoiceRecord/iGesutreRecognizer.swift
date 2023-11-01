//
//  iGesutreRecognizer.swift
//  UltraCore
//
//  Created by Slam on 10/24/23.
//

import UIKit

class iGesutreRecognizer: UIGestureRecognizer {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard state != .began else {
            return
        }
        state = .began
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }

}
