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
    
    var mouthpieceOnImage: TwiceImage { get set }
    
    var mouthpieceOffImage: TwiceImage { get set }
    
    var micOnImage: TwiceImage { get set }
    var micOffImage: TwiceImage { get set }
    
    var cameraOnImage: TwiceImage { get set }
    var cameraOffImage: TwiceImage { get set }
    
    var answerImage: TwiceImage { get set }
    var declineImage: TwiceImage { get set }
    
    var switchFrontCameraImage: TwiceImage { get set }
    var switchBackCameraImage: TwiceImage { get set }
}
