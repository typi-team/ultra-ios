//
//  ContactsStrings.swift
//  UltraCore
//
//  Created by Slam on 8/7/23.
//

import Foundation

enum ContactsStrings: String, StringLocalizable {
    case newChat
    
    case wasMonths1 = "was.months.1"
    case wasMonths2 = "was.months.2"
    case wasMonths5 = "was.months.5"
    
    case wasDays1 = "was.days.1"
    case wasDays2 = "was.days.2"
    case wasDays5 = "was.days.5"
    
    case wasHours1 = "was.hours.1"
    case wasHours2 = "was.hours.2"
    case wasHours5 = "was.hours.5"
    
    case wasMinutes1 = "was.minutes.1"
    case wasMinutes2 = "was.minutes.2"
    case wasMinutes5 = "was.minutes.5"
    
    case wasJustNow = "was.justNow"
    case wasYesterday = "was.yesterday"
    case wasLongTimeAgo = "was.longTimeAgo"
    
    case yourContactListIsEmpty
    case unfortunately
    case noAccessToContacts
    case clickToShareContacts
    
    case grantAccess
    
    case minuteSingularForm
    case minutePluralForm
    case minutePluralForm2
    case hourSingularForm
    case hourPluralForm
    case hourPluralForm2
    
    
    var prefixOfTemplate: String { "contacts" }
    var localizableValue: String { rawValue }
}
