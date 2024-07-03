//
//  VoiceInputBarConfig.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import UIKit

public protocol VoiceInputBarConfig {
    var background: TwiceColor { get set }
    var waveBackground: TwiceColor { get set }
    var durationLabel: LabelConfig { get set }
    var recordBackground: TwiceColor { get set }
    var roundedViewBackground: TwiceColor { get set }
    var removeButtonBackground: TwiceColor { get set }
    var recordButtonDefaultImage: TwiceImage { get set }
    var recordButtonRecordingImage: TwiceImage { get set }
    var smallMicImage: TwiceImage { get set }
    var bucketLidImage: TwiceImage { get set }
    var bucketBodyImage: TwiceImage { get set }
}
