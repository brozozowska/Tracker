//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Сергей Розов on 04.10.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        //isRecording = false
        UIView.setAnimationsEnabled(false)
    }

    // MARK: - Fixed date
    private func fixedDate() -> Date {
        var comps = DateComponents()
        comps.year = 2025
        comps.month = 10
        comps.day = 4
        comps.hour = 12
        return Calendar.current.date(from: comps)!
    }

    // MARK: - Helpers
    private func makeTrackersNavigationController() -> UINavigationController {
        let viewController = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        _ = viewController.view

        if let datePicker = viewController.navigationItem.rightBarButtonItem?.customView as? UIDatePicker {
            datePicker.date = fixedDate()
            datePicker.sendActions(for: .valueChanged)
        }

        let weekday = WeekDay(from: fixedDate())
        
        let tracker = Tracker(
            title: "Drink water",
            color: UIColor.systemBlue,
            emoji: "💧",
            schedule: [weekday]
        )

        let category = TrackerCategory(title: "Health", trackers: [tracker])
        
        viewController.categories = [category]

        return navigationController
    }

    // MARK: - Snapshot tests
    func testTrackersScreenLight() {
        let nav = makeTrackersNavigationController()
        assertSnapshot(
            of: nav,
            as: .image(traits: UITraitCollection(userInterfaceStyle: .light))
        )
    }

    func testTrackersScreenDark() {
        let nav = makeTrackersNavigationController()
        assertSnapshot(
            of: nav,
            as: .image(traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
