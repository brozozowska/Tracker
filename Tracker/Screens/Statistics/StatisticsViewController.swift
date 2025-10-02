//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 09.08.2025.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - UI Constants
    private enum UIConstants {
        static let emptyImageSize: CGFloat = 80
        static let emptyLabelSpacing: CGFloat = 8
        static let rowHeight: CGFloat = 104
        static let verticalOffset: CGFloat = 55
        static let horizontalInset: CGFloat = 16
    }
    
    // MARK: - Metrics
    private enum Metric: Int, CaseIterable {
        case bestPeriod
        case perfectDays
        case completedTotal
        case averagePerDay
        
        var title: String {
            switch self {
            case .bestPeriod:
                return NSLocalizedString("statistics.best_period", comment: "Best period metric title")
            case .perfectDays:
                return NSLocalizedString("statistics.perfect_days", comment: "Perfect days metric title")
            case .completedTotal:
                return NSLocalizedString("statistics.completed_total", comment: "Completed trackers total metric title")
            case .averagePerDay:
                return NSLocalizedString("statistics.average_per_day", comment: "Average per active day metric title")
            }
        }
    }
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = UIConstants.rowHeight
        table.dataSource = self
        table.isScrollEnabled = false
        table.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.reuseId)
        return table
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyStat)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.empty.title", comment: "Statistics empty state text")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    // MARK: - Stores & Service
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    private lazy var statisticsService = StatisticsService(
        trackerStore: trackerStore,
        recordStore: recordStore
    )
    
    // MARK: - State
    private var stats: Statistics = .zero
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        addSubviews()
        setupLayout()
        
        trackerStore.delegate = self
        recordStore.delegate = self
        
        recomputeAndReload()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("statistics.title", comment: "Statistics screen title")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func addSubviews() {
        [
            tableView,
            emptyStateImageView,
            emptyStateLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.verticalOffset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: UIConstants.emptyImageSize),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: UIConstants.emptyImageSize),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: UIConstants.emptyLabelSpacing)
        ])
    }
    
    // MARK: - Private Methods
    private func recomputeAndReload() {
        stats = statisticsService.compute()
        updateEmptyStateVisibility()
        tableView.reloadData()
    }
    
    private func updateEmptyStateVisibility() {
        let isEmpty = stats.completedTotal == 0
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return Metric.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let metric = Metric(rawValue: indexPath.row),
            let cell = tableView.dequeueReusableCell(
                withIdentifier: StatisticsCell.reuseId,
                for: indexPath
            ) as? StatisticsCell
        else {
            return UITableViewCell()
        }
        
        let value: Int
        switch metric {
        case .bestPeriod: value = stats.bestPeriod
        case .perfectDays: value = stats.perfectDays
        case .completedTotal: value = stats.completedTotal
        case .averagePerDay: value = stats.averagePerActiveDay
        }
        
        cell.configure(title: metric.title, value: value)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - TrackerStoreDelegate
extension StatisticsViewController: TrackerStoreDelegate {
    func storeDidUpdate(_ trackers: [Tracker]) {
        recomputeAndReload()
    }
}

// MARK: - TrackerRecordStoreDelegate
extension StatisticsViewController: TrackerRecordStoreDelegate {
    func storeDidUpdate(_ records: [TrackerRecord]) {
        recomputeAndReload()
    }
}
