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
