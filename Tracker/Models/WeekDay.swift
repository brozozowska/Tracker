//
//  WeekDay.swift
//  Tracker
//
//  Created by Сергей Розов on 27.08.2025.
//

import Foundation

enum WeekDay: String, CaseIterable, Codable {
    case monday = "weekday.monday"
        case tuesday = "weekday.tuesday"
        case wednesday = "weekday.wednesday"
        case thursday = "weekday.thursday"
        case friday = "weekday.friday"
        case saturday = "weekday.saturday"
        case sunday = "weekday.sunday"
    
    var longName: String {
        NSLocalizedString("\(rawValue).long", comment: "Full weekday name")
    }
    
    var shortName: String {
        NSLocalizedString("\(rawValue).short", comment: "Short weekday name")
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
            return NSLocalizedString("schedule.everyday", comment: "Every day")
        } else if selected == workdays {
            return NSLocalizedString("schedule.workdays", comment: "Workdays")
        } else if selected == weekend {
            return NSLocalizedString("schedule.weekend", comment: "Weekend")
        } else {
            let sortedDays = WeekDay.allCases.filter { selected.contains($0) }
            let names = sortedDays.map { $0.shortName }
            return ListFormatter.localizedString(byJoining: names)
        }
    }
}
