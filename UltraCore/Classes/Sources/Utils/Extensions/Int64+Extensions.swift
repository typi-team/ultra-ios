//
//  Int64+Extensions.swift
//  UltraCore
//
//  Created by Slam on 5/19/23.
//

import Foundation

extension Int64 {
    
    enum Format: String {
        case hourAndMinute = "HH:mm"
        case dayAndHourMinute = "d MMMM в HH:mm"
    }
    
    var date: Date { Date.init(nanoseconds: self)}
    
    ///  Возращает дату по формату
    /// - Parameter format: Формат даты
    /// - Returns: Отформатированная дата
    func dateBy(format: Format) -> String {
        kDateFormatter.dateFormat = format.rawValue
        return kDateFormatter.string(from: date)
    }
    
    /// Возврщает дату по формату но с добавление типа "Н минут назад" и "сегодня"
    /// - Parameter format: Формат даты
    /// - Returns: Отформатированная дата
    func date(format: Format) -> String {
        kDateFormatter.dateFormat = format.rawValue
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.allowedUnits = [.minute]
        componentsFormatter.unitsStyle = .full
        
        let date = Date(nanoseconds: self)
        let formattedDate = kDateFormatter.string(from: date)
        if let timeAgo = componentsFormatter.string(from: date, to: Date()), let minutes = Int(timeAgo.split(separator: " ")[0]) {
            if minutes <= 1 {
                return "только что"
            } else if minutes <= 5 {
                return "был \(timeAgo) назад"
            } else {
                return formattedDate
            }
        } else {
            return formattedDate
        }
    }
}

