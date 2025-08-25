//
//  TrackerModels.swift
//  Tracker
//
//  Created by Сергей Розов on 15.08.2025.
//

import UIKit

// MARK: - WeekDay
enum WeekDay: String, CaseIterable {
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

// MARK: - Tracker
struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    
    init(
        id: UUID = UUID(),
        title: String,
        color: UIColor,
        emoji: String,
        schedule: [WeekDay]
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}

// MARK: - TrackerCategory
struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

// MARK: - TrackerRecord
struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}

// MARK: - Formatted WeekDay
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
