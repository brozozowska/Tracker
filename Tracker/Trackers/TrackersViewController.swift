//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 09.08.2025.
//

import UIKit

class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .empty)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Public Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Private Properties
    private var selectedDate: Date = Date()
    private var visibleTrackers: [Tracker] {
        let currentWeekDay = weekDay(for: selectedDate)
        return categories.flatMap { $0.trackers }.filter { tracker in
            tracker.schedule.contains(currentWeekDay)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupCollectionView()
        addSubviews()
        setupLayout()
    }
    
    // MARK: - Actions
    @objc private func addTrackerTapped() {
        let currentWeekDay = weekDay(for: selectedDate)
        let newTracker = Tracker(
            title: "Новый трекер",
            color: .systemBlue,
            emoji: "🔥",
            schedule: [currentWeekDay]
        )
        
        if categories.isEmpty {
            let newCategory = TrackerCategory(title: "Категория 1", trackers: [newTracker])
            categories = [newCategory]
        } else {
            var firstCategory = categories[0]
            firstCategory = TrackerCategory(
                title: firstCategory.title,
                trackers: firstCategory.trackers + [newTracker]
            )
            categories[0] = firstCategory
        }

        collectionView.reloadData()
        
        updateEmptyStateVisibility()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTrackerTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
    }

    private func addSubviews() {
        [
            collectionView,
            emptyStateImageView,
            emptyStateLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8)
        ])
    }
    
    // MARK: - Private Methods
    private func toggleTrackerCompletion(_ tracker: Tracker) {
        if selectedDate > Date() {
            return
        }
        
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        ) {
            completedTrackers.remove(at: index)
        } else {
            let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
            completedTrackers.append(record)
        }
        
        guard let itemIndex = visibleTrackers.firstIndex(where: { $0.id == tracker.id }) else { return }
        
        let indexPath = IndexPath(item: itemIndex, section: 0)
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    private func updateEmptyStateVisibility() {
        let isEmpty = visibleTrackers.isEmpty
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
    }
    
    private func weekDay(for date: Date) -> WeekDay {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        switch weekdayNumber {
        case 1: return .monday
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        case 6: return .saturday
        case 7: return .sunday
        default: return .monday
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return visibleTrackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = visibleTrackers[indexPath.item]
        let completedRecords = completedTrackers.filter { $0.trackerId == tracker.id }
        let completedCount = completedRecords.count
        
        let isCompletedToday = completedRecords.contains {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
        
        cell.configure(completedCount: completedCount, isCompletedToday: isCompletedToday)
        cell.buttonTapped = { [weak self] in
            self?.toggleTrackerCompletion(tracker)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 2
        return CGSize(width: width, height: 100)
    }
}
