//
//  NSObject+Ext.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import Foundation

public protocol WithCreation: AnyObject {}

extension NSObject: WithCreation {}

public extension WithCreation where Self: NSObject {
    init(_ closure: (Self) -> Void) {
        self.init()
        closure(self)
    }
}


extension String {
    var url: URL? { URL(string: self) }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
        @objc class ClosureSleeve: NSObject {
            let closure: () -> Void
            init(_ closure: @escaping () -> Void) { self.closure = closure }
            @objc func invoke() { closure() }
        }
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, "\(UUID())", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

extension Int64 {
    func formattedTime(format: String = "HH:mm") -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    var date: Date { Date.init(nanoseconds: self)}
}

extension Date {
    var nanosec: Int64 { Int64(timeIntervalSince1970 * 1000 * 1000) }

    init(nanoseconds: Int64) { self = Date(timeIntervalSince1970: TimeInterval(nanoseconds / 1000 / 1000)) }

    func formattedTime(format: String = "HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

