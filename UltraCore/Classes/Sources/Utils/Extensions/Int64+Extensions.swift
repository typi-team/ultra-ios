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
    
    var timeInterval: TimeInterval { TimeInterval(self) / 1000000}
    
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
        
        let startDate = Date(nanoseconds: self)
        let endDate = Date()

        return getTimeText(start: startDate, end: endDate)
    }
}

func getTimeText(start: Date, end: Date) -> String {
    let calendar = Calendar.current

    // Получите компоненты времени между начальной и конечной датой
    let components = calendar.dateComponents([.month, .day, .hour, .minute], from: start, to: end)

    // Извлеките компоненты времени
    let months = components.month ?? 0
    let days = components.day ?? 0
    let hours = components.hour ?? 0
    let minutes = components.minute ?? 0

    PP.debug("[Last seen] - \(months) months, \(days) days, \(hours) hours, \(minutes) ago")
    
    // Определите текст в зависимости от разницы времени
    if months > 12 {
        return ContactsStrings.wasLongTimeAgo.localized
    } else if months > 0 {
        return pluralize(
            value: months,
            forms: [ContactsStrings.wasMonths1, ContactsStrings.wasMonths2, ContactsStrings.wasMonths5].map(\.localized)
        )
    } else if days > 1 {
        return pluralize(
            value: days,
            forms: [ContactsStrings.wasDays1, ContactsStrings.wasDays2, ContactsStrings.wasDays5].map(\.localized)
        )
    } else if days == 1 {
        return ContactsStrings.wasYesterday.localized
    } else if hours > 0 {
        return pluralize(
            value: hours,
            forms: [ContactsStrings.wasHours1, ContactsStrings.wasHours2, ContactsStrings.wasHours5].map(\.localized)
        )
    } else if minutes > 0 {
        return pluralize(
            value: minutes,
            forms: [ContactsStrings.wasMinutes1, ContactsStrings.wasMinutes2, ContactsStrings.wasMinutes5].map(\.localized)
        )
    } else {
        return ContactsStrings.wasJustNow.localized
    }
}

// Функция для склонения слова в зависимости от числа
func pluralize(value: Int, forms: [String]) -> String {
    let mod10 = value % 10
    let mod100 = value % 100

    if mod10 == 1 && mod100 != 11 {
        return String(format: forms[0], value)
    } else if mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20) {
        return String(format: forms[1], value)
    } else {
        return String(format: forms[2], value)
    }
}
