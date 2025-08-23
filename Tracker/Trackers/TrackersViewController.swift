//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 09.08.2025.
//

import UIKit

class TrackersViewController: UIViewController {
    
    // MARK: - Constants
    private enum UIConstants {
        static let horizontalInset: CGFloat = 16
        static let emptyImageSize: CGFloat = 80
        static let emptyLabelSpacing: CGFloat = 8
        static let cellHeight: CGFloat = 100
        static let cellSpacing: CGFloat = 16
    }
    
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
    var categories: [TrackerCategory] = [] {
        didSet { updateVisibleTrackers() }
    }
    
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Private Properties
    private var selectedDate: Date = Date() {
        didSet { updateVisibleTrackers() }
    }
    
    private var visibleTrackers: [Tracker] = []

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupCollectionView()
        addSubviews()
        setupLayout()
        
        updateVisibleTrackers()
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
        datePicker.locale = Locale(identifier: "ru_RU")
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
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: UIConstants.emptyImageSize),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: UIConstants.emptyImageSize),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: UIConstants.emptyLabelSpacing)
        ])
    }
    
    // MARK: - Private Methods
    private func updateVisibleTrackers() {
        let currentWeekDay = weekDay(for: selectedDate)
        visibleTrackers = categories.flatMap { $0.trackers }.filter { $0.schedule.contains(currentWeekDay) }
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    private func updateEmptyStateVisibility() {
        let isEmpty = visibleTrackers.isEmpty
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
    }
    
    private func toggleTrackerCompletion(_ tracker: Tracker) {
        if selectedDate > Date() { return }
                
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            completedTrackers.remove(at: index)
        } else {
            let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
            completedTrackers.append(record)
        }
        
        if let itemIndex = visibleTrackers.firstIndex(where: { $0.id == tracker.id }) {
            collectionView.reloadItems(at: [IndexPath(item: itemIndex, section: 0)])
        }
    }
    
    private func weekDay(for date: Date) -> WeekDay {
        let calendar = Calendar.current
        let weekdayIndex = (calendar.component(.weekday, from: date) + 5) % 7
        return WeekDay.allCases[weekdayIndex]
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
        let width = (collectionView.bounds.width - UIConstants.cellSpacing) / 2
        return CGSize(width: width, height: UIConstants.cellHeight)
    }
}
