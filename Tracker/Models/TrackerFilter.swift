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
            NSLocalizedString("filters.all", comment: "All trackers")
        case .today:
            NSLocalizedString("filters.today", comment: "Trackers for today")
        case .completed:
            NSLocalizedString("filters.completed", comment: "Completed trackers")
        case .uncompleted:
            NSLocalizedString("filters.uncompleted", comment: "Uncompleted trackers")
        }
    }
}
