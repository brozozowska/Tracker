//
//  Tracker.swift
//  Tracker
//
//  Created by Сергей Розов on 27.08.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    
    init(
        id: UUID = UUID(),
        title: String,
        color: NSObject,
        emoji: String,
        schedule: [WeekDay]
    ) {
        self.id = id
        self.title = title
        self.color = (color as? UIColor) ?? .clear
        self.emoji = emoji
        self.schedule = schedule
    }
}
