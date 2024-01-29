//
//  ReportViewStyle.swift
//  UltraCore
//
//  Created by Slam on 1/29/24.
//

import Foundation

public protocol ReportViewStyle {
    var spam: TwiceImage? { get set }
    var personalData: TwiceImage? { get set }
    var fraud: TwiceImage? { get set }
    var impositionOfServices: TwiceImage? { get set }
    var insult: TwiceImage? { get set }
    var other: TwiceImage? { get set }
    var report: TwiceImage? { get set }
}


struct ReportViewStyleImpl: ReportViewStyle {
    var spam: TwiceImage? = TwiceImageImpl.init(dark: .named("message.cell.trash")!, default: .named("message.cell.trash")!)
    var personalData: TwiceImage? = TwiceImageImpl(dark: .named("message.cell.personalData")!, default: .named("message.cell.personalData")!)
    var fraud: TwiceImage? = TwiceImageImpl(dark: .named("message.cell.fraud")!, default: .named("message.cell.fraud")!)
    var impositionOfServices: TwiceImage? = TwiceImageImpl(dark: .named("message.cell.impositionOfServices")!, default: .named("message.cell.impositionOfServices")!)
    var insult: TwiceImage? = TwiceImageImpl(dark: .named("message.cell.insult")!, default: .named("message.cell.insult")!)
    var other: TwiceImage? = TwiceImageImpl(dark: .named("message.cell.other")!, default: .named("message.cell.other")!)
    var report: TwiceImage? = TwiceImageImpl(dark: .named("message.cell.report")!, default: .named("message.cell.report")!)
    
}
