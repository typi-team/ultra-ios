//
//  CallPageStyle.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import Foundation

public protocol CallPageStyle {
    var background: TwiceColor { get set }
    var backButtonTint: TwiceColor { get set }
    
    var companionConfig: LabelConfig { get set }
    var durationConfig: LabelConfig { get set }
    
    var companionVideoConfig: LabelConfig { get set }
    var durationVideoConfig: LabelConfig { get set }
    
    var mouthpieceOnImage: UIImage { get set }
    
    var mouthpieceOffImage: UIImage { get set }
    
    var micOnImage: UIImage { get set }
    var micOffImage: UIImage { get set }
    
    var cameraOnImage: UIImage { get set }
    var cameraOffImage: UIImage { get set }
    
    var answerImage: UIImage { get set }
    var declineImage: UIImage { get set }
    
    var switchFrontCameraImage: UIImage { get set }
    var switchBackCameraImage: UIImage { get set }
}
