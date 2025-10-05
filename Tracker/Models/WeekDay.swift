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
        Localizable.Weekday.long(self)
    }
    
    var shortName: String {
        Localizable.Weekday.short(self)
    }
    
    static var workdays: [WeekDay] {
        [.monday, .tuesday, .wednesday, .thursday, .friday]
    }
    
    static var weekend: [WeekDay] {
        [.saturday, .sunday]
    }
}

extension WeekDay {
    init(from date: Date, calendar: Calendar = .current) {
        let index = (calendar.component(.weekday, from: date) + 5) % 7
        self = WeekDay.allCases[index]
    }
}

extension Array where Element == WeekDay {
    func formattedWeekDay() -> String {
        let allDays = Set(WeekDay.allCases)
        let workdays = Set(WeekDay.workdays)
        let weekend = Set(WeekDay.weekend)
        let selected = Set(self)
        
        if selected == allDays {
            return Localizable.Schedule.everyday
        } else if selected == workdays {
            return Localizable.Schedule.workdays
        } else if selected == weekend {
            return Localizable.Schedule.weekend
        } else {
            let sortedDays = WeekDay.allCases.filter { selected.contains($0) }
            let names = sortedDays.map { $0.shortName }
            return ListFormatter.localizedString(byJoining: names)
        }
    }
}
