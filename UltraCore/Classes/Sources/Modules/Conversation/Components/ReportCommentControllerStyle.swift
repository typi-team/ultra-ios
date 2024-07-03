//
//  ReportCommentControllerStyle.swift
//  UltraCore
//
//  Created by Slam on 1/8/24.
//

import UIKit

public protocol ReportCommentControllerStyle {
    var backgroundColor: TwiceColor { get set }

    var headlineImage: TwiceImage { get set }
    var headlineConfig: LabelConfig { get set }
    var textFieldConfig: LabelConfig { get set }
    var textFieldBackgroundColor: TwiceColor { get set }
    var textFieldEraseImage: TwiceImage { get set }
    var reportButtonConfig: ElevatedButtonStyle { get set }
    var cancelButtonConfig: ElevatedButtonStyle { get set }
}

class ReportCommentControllerStyleImpl: ReportCommentControllerStyle {
    var backgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .gray100, darkColor: .gray100)
    
    var headlineImage: TwiceImage = TwiceImageImpl(dark: .fromAssets( "conversation.report.placeholder")!, default: .fromAssets("conversation.report.placeholder")!)
    
    var headlineConfig: LabelConfig = LabelConfigImpl.init(darkColor: .white, defaultColor: .gray700,
                                                        font: .defaultRegularCallout,
                                                        placeholder: MessageStrings.comment.localized,
                                                        tintColor: TwiceColorImpl(defaultColor: .black, darkColor: .white))
    
    var textFieldConfig: LabelConfig = LabelConfigImpl.init(darkColor: .white, defaultColor: .gray700,
                                                            font: .defaultRegularCallout,
                                                            placeholder: MessageStrings.comment.localized,
                                                            tintColor: TwiceColorImpl(defaultColor: .black, darkColor: .white))
    
    var textFieldBackgroundColor: TwiceColor = TwiceColorImpl(defaultColor: .white, darkColor: .clear)
    
    var textFieldEraseImage: TwiceImage = TwiceImageImpl(dark: .named("conversation_erase")!, default: .named("conversation_erase")!)
    
    var reportButtonConfig: ElevatedButtonStyle = ElevatedButtonStyleImpl()
    
    var cancelButtonConfig: ElevatedButtonStyle = ElevatedButtonStyleImpl(backgroundColor: TwiceColorImpl(defaultColor: .white, darkColor: .white), titleConfig: LabelConfigImpl(darkColor: .gray700, defaultColor: .gray700, font: .defaultRegularCallout))
}
