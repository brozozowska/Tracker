//
//  WeekDay.swift
//  Tracker
//
//  Created by Сергей Розов on 27.08.2025.
//

import Foundation

enum WeekDay: String, CaseIterable, Codable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    static var workdays: [WeekDay] {
        return [.monday, .tuesday, .wednesday, .thursday, .friday]
    }
    
    static var weekend: [WeekDay] {
        return [.saturday, .sunday]
    }
}

extension Array where Element == WeekDay {
    func formattedWeekDay() -> String {
        let allDays = Set(WeekDay.allCases)
        let workdays = Set(WeekDay.workdays)
        let weekend = Set(WeekDay.weekend)
        let selected = Set(self)
        
        if selected == allDays {
            return "Каждый день"
        } else if selected == workdays {
            return "Будние дни"
        } else if selected == weekend {
            return "Выходные"
        } else {
            let sortedDays = WeekDay.allCases.filter { selected.contains($0) }
            return sortedDays.map { $0.shortName }.joined(separator: ", ")
        }
    }
}
