//
//  StatisticsService.swift
//  Tracker
//
//  Created by Сергей Розов on 02.10.2025.
//

import Foundation

struct Statistics {
    let bestPeriod: Int
    let perfectDays: Int
    let completedTotal: Int
    let averagePerActiveDay: Int
    
    static let zero = Statistics(bestPeriod: 0, perfectDays: 0, completedTotal: 0, averagePerActiveDay: 0)
}

// MARK: - Protocol
protocol StatisticsServiceProtocol {
    func compute() -> Statistics
}

// MARK: - StatisticsService
final class StatisticsService: StatisticsServiceProtocol {
    
    // MARK: - Dependencies
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    private let calendar: Calendar
    
    // MARK: - Initializers
    init(
        trackerStore: TrackerStore = TrackerStore(),
        recordStore: TrackerRecordStore = TrackerRecordStore(),
        calendar: Calendar = .current
    ) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        self.calendar = calendar
    }
    
    // MARK: - Public Methods
    func compute() -> Statistics {
        let trackers = trackerStore.fetchTrackers()
        let records = recordStore.fetchRecords()
        
        guard !records.isEmpty else { return .zero }
        
        var recordsByDate: [Date: Set<UUID>] = [:]
        var activeDates = Set<Date>()
        for record in records {
            let day = calendar.startOfDay(for: record.date)
            activeDates.insert(day)
            var set = recordsByDate[day] ?? Set<UUID>()
            set.insert(record.trackerId)
            recordsByDate[day] = set
        }
        
        let completedTotal = records.count
        let activeDaysCount = activeDates.count
        let average = activeDaysCount > 0
        ? Int((Double(completedTotal) / Double(activeDaysCount)).rounded())
        : 0
        
        let bestPeriod = maxConsecutiveDays(in: activeDates)
        
        let perfectDays = countPerfectDays(
            dates: activeDates,
            trackers: trackers,
            recordsByDate: recordsByDate
        )
        
        return Statistics(
            bestPeriod: bestPeriod,
            perfectDays: perfectDays,
            completedTotal: completedTotal,
            averagePerActiveDay: average
        )
    }
    
    // MARK: - Helpers
    private func maxConsecutiveDays(in dateSet: Set<Date>) -> Int {
        guard !dateSet.isEmpty else { return 0 }
        let sorted = dateSet.sorted()
        var best = 1
        var current = 1
        for i in 1..<sorted.count {
            if let prev = calendar.date(byAdding: .day, value: 1, to: sorted[i - 1]),
               calendar.isDate(prev, inSameDayAs: sorted[i]) {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }
        return best
    }
    
    private func countPerfectDays(
        dates: Set<Date>,
        trackers: [Tracker],
        recordsByDate: [Date: Set<UUID>]
    ) -> Int {
        guard !dates.isEmpty, !trackers.isEmpty else { return 0 }
        let sortedDates = dates.sorted()
        var count = 0
        
        for date in sortedDates {
            let weekday = WeekDay(from: date, calendar: calendar)
            let scheduled = trackers.filter { $0.schedule.contains(weekday) }
            guard !scheduled.isEmpty else { continue }
            
            let completed = recordsByDate[date] ?? []
            let allDone = scheduled.allSatisfy { completed.contains($0.id) }
            if allDone { count += 1 }
        }
        
        return count
    }
}
