//
//  Localizable.swift
//  Tracker
//
//  Created by Сергей Розов on 03.10.2025.
//

import Foundation

enum Localizable {
    
    enum Actions {
        static var edit: String {
            NSLocalizedString("edit.action", comment: "Edit action")
        }
        static var delete: String {
            NSLocalizedString("delete.action", comment: "Delete action")
        }
        static var cancel: String {
            NSLocalizedString("cancel.action", comment: "Cancel action")
        }
        static var create: String {
            NSLocalizedString("create.action", comment: "Create action")
        }
        static var save: String {
            NSLocalizedString("save.action", comment: "Save action")
        }
        static var done: String {
            NSLocalizedString("done.action", comment: "Done button")
        }
    }

    enum Onboarding {
        static var page1Text: String {
            NSLocalizedString("onboarding.page1.text", comment: "First onboarding page text")
        }
        static var page2Text: String {
            NSLocalizedString("onboarding.page2.text", comment: "Second onboarding page text")
        }
        static var actionTitle: String {
            NSLocalizedString("onboarding.action.title", comment: "Onboarding primary action title")
        }
    }
    
    enum Search {
        static var placeholder: String {
            NSLocalizedString("search.placeholder", comment: "Search placeholder")
        }
    }
    
    enum Tabs {
        static var trackers: String {
            NSLocalizedString("tab.trackers.title", comment: "Trackers tab title")
        }
        static var statistics: String {
            NSLocalizedString("tab.statistics.title", comment: "Statistics tab title")
        }
    }
    
    enum Trackers {
        static var title: String {
            NSLocalizedString("trackers.title", comment: "Trackers screen title")
        }
        static var emptyTitle: String {
            NSLocalizedString("trackers.empty.title", comment: "Empty state label text on trackers screen")
        }
        static var searchEmptyTitle: String {
            NSLocalizedString("trackers.search.empty.title", comment: "Nothing found empty state label")
        }
        static var deleteConfirmMessage: String {
            NSLocalizedString("trackers.delete.confirm.message", comment: "Confirm tracker deletion message")
        }
    }
    
    enum Tracker {
        static func daysCount(_ count: Int) -> String {
            String.localizedStringWithFormat(
                NSLocalizedString("tracker.days.count", comment: "Completed days count"),
                count
            )
        }
    }
    
    enum NewTracker {
        static var title: String {
            NSLocalizedString("new_tracker.title", comment: "New tracker screen title")
        }
        static var editTitle: String {
            NSLocalizedString("edit_tracker.title", comment: "Edit tracker screen title")
        }
        static var namePlaceholder: String {
            NSLocalizedString("new_tracker.name.placeholder", comment: "Placeholder for tracker name")
        }
        static var categoryTitle: String {
            NSLocalizedString("category.title", comment: "Category option title")
        }
        static var scheduleTitle: String {
            NSLocalizedString("schedule.title", comment: "Schedule option title")
        }
        static var emojiTitle: String {
            NSLocalizedString("emoji.title", comment: "Emoji section title")
        }
        static var colorTitle: String {
            NSLocalizedString("color.title", comment: "Color section title")
        }
    }
    
    enum Categories {
        static var screenTitle: String {
            NSLocalizedString("category.title", comment: "Category screen title")
        }
        static var emptyMessage: String {
            NSLocalizedString("categories.empty.message", comment: "Categories empty state message")
        }
        static var addButton: String {
            NSLocalizedString("category.add_button", comment: "Add category button")
        }
        static var deleteConfirm: String {
            NSLocalizedString("delete_category.confirm_message", comment: "Confirm delete category")
        }
        static var uncategorizedTitle: String {
            NSLocalizedString("category.uncategorized.title", comment: "Title for 'No category'")
        }
    }
    
    enum CategoryEditor {
        static var newTitle: String {
            NSLocalizedString("new_category.title", comment: "New category screen title")
        }
        static var editTitle: String {
            NSLocalizedString("edit_category.title", comment: "Edit category screen title")
        }
        static var namePlaceholder: String {
            NSLocalizedString("new_category.name.placeholder", comment: "Category name placeholder")
        }
    }
    
    enum Filters {
        static var title: String {
            NSLocalizedString("filters.title", comment: "Filters title")
        }
        static var all: String {
            NSLocalizedString("filters.all", comment: "All trackers")
        }
        static var today: String {
            NSLocalizedString("filters.today", comment: "Trackers for today")
        }
        static var completed: String {
            NSLocalizedString("filters.completed", comment: "Completed trackers")
        }
        static var uncompleted: String {
            NSLocalizedString("filters.uncompleted", comment: "Uncompleted trackers")
        }
    }
    
    enum Statistics {
        static var title: String {
            NSLocalizedString("statistics.title", comment: "Statistics screen title")
        }
        static var emptyTitle: String {
            NSLocalizedString("statistics.empty.title", comment: "Statistics empty state text")
        }
        static var bestPeriod: String {
            NSLocalizedString("statistics.best_period", comment: "Best period metric title")
        }
        static var perfectDays: String {
            NSLocalizedString("statistics.perfect_days", comment: "Perfect days metric title")
        }
        static var completedTotal: String {
            NSLocalizedString("statistics.completed_total", comment: "Completed trackers total metric title")
        }
        static var averagePerDay: String {
            NSLocalizedString("statistics.average_per_day", comment: "Average per active day metric title")
        }
    }

    enum Schedule {
        static var screenTitle: String {
            NSLocalizedString("schedule.title", comment: "Schedule screen title")
        }
        static var everyday: String {
            NSLocalizedString("schedule.everyday", comment: "Every day")
        }
        static var workdays: String {
            NSLocalizedString("schedule.workdays", comment: "Workdays")
        }
        static var weekend: String {
            NSLocalizedString("schedule.weekend", comment: "Weekend")
        }
    }
    
    enum Weekday {
        static func long(_ day: WeekDay) -> String {
            NSLocalizedString("\(day.rawValue).long", comment: "Full weekday name")
        }
        static func short(_ day: WeekDay) -> String {
            NSLocalizedString("\(day.rawValue).short", comment: "Short weekday name")
        }
    }
}
