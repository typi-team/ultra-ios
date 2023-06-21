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
        
        let startDate = Date(nanoseconds: self)
        let endDate = Date()

        return getTimeText(start: startDate, end: endDate)
    }
}

func getTimeText(start: Date, end: Date) -> String {
    let calendar = Calendar.current

    // Получите компоненты времени между начальной и конечной датой
    let components = calendar.dateComponents([.day, .hour, .minute], from: start, to: end)

    // Извлеките компоненты времени
    let days = components.day ?? 0
    let hours = components.hour ?? 0
    let minutes = components.minute ?? 0

    // Определите текст в зависимости от разницы времени
    if days > 1 {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let dateString = formatter.string(from: start)
        return "был(а) \(dateString)"
    } else if days == 1 {
        let formatter = DateFormatter()
        formatter.dateFormat = "вчера в HH:mm"
        return "был(а) \(formatter.string(from: start))"
    } else if hours > 0 {
        let hourString = pluralize(value: hours, singularForm: "час", pluralForm: "часа", pluralForm2: "часов")
        return "был(а) \(hourString) назад"
    } else if minutes > 0 {
        let minuteString = pluralize(value: minutes, singularForm: "минуту", pluralForm: "минуты", pluralForm2: "минут")
        return "был(а) \(minuteString) назад"
    } else {
        return "был(а) только что"
    }
}

// Функция для склонения слова в зависимости от числа
func pluralize(value: Int, singularForm: String, pluralForm: String, pluralForm2: String) -> String {
    let mod10 = value % 10
    let mod100 = value % 100

    if mod10 == 1 && mod100 != 11 {
        return "\(value) \(singularForm)"
    } else if mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20) {
        return "\(value) \(pluralForm)"
    } else {
        return "\(value) \(pluralForm2)"
    }
}

enum ContactString: String {
    case seenNMinutesAgo = "last seen %d minutes ago"
    case nHourAgo = "last seen %d hours ago"
}

extension String {
    var localized: String {
       return NSLocalizedString(self, comment: self)
   }
}
