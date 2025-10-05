//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Сергей Розов on 03.10.2025.
//

import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted
    
    var title: String {
        switch self {
        case .all:
            Localizable.Filters.all
        case .today:
            Localizable.Filters.today
        case .completed:
            Localizable.Filters.completed
        case .uncompleted:
            Localizable.Filters.uncompleted
        }
    }
}
