//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 09.08.2025.
//

import UIKit

final class TrackersViewController: UIViewController, NewTrackerViewControllerDelegate {
    
    // MARK: - Constants
    private enum UIConstants {
        static let horizontalInset: CGFloat = 16
        static let emptyImageSize: CGFloat = 80
        static let emptyLabelSpacing: CGFloat = 8
        static let cellHeight: CGFloat = 148
        static let cellSpacing: CGFloat = 16
    }
    
    // MARK: - UI Elements
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .empty)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
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
    
    private var visibleCategories: [TrackerCategory] = []
    
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    private var trackers: [Tracker] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupCollectionView()
        addSubviews()
        setupLayout()
        
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        
        trackers = trackerStore.fetchTrackers()
        categories = categoryStore.fetchCategories()
        completedTrackers = recordStore.fetchRecords()
        
        updateVisibleTrackers()
    }
    
    // MARK: - Actions
    @objc private func addTrackerTapped() {        
        let creator = NewTrackerViewController()
        creator.delegate = self
        
        let navigationController = UINavigationController(rootViewController: creator)
        navigationController.modalPresentationStyle = .pageSheet
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
        }
        
        present(navigationController, animated: true)
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
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.reuseIdentifier
        )
        collectionView.register(
            CategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryHeaderView.reuseIdentifier
        )
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
        let grouped = Dictionary(grouping: categories, by: { $0.title })
        visibleCategories = grouped.compactMap { (title, categoriesGroup) in
            let trackers = categoriesGroup.flatMap { $0.trackers }
                .filter { $0.schedule.contains(currentWeekDay) }
            return trackers.isEmpty ? nil : TrackerCategory(title: title, trackers: trackers)
        }
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    private func updateEmptyStateVisibility() {
        let isEmpty = visibleCategories.isEmpty
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
    }
    
    private func toggleTrackerCompletion(_ tracker: Tracker) {
        if selectedDate > Date() { return }
        
        if let record = recordStore.record(for: tracker.id, on: selectedDate) {
            try? recordStore.deleteRecord(record)
            completedTrackers.removeAll { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        } else {
            let newRecord = TrackerRecord(trackerId: tracker.id, date: Calendar.current.startOfDay(for: selectedDate))
            do {
                try recordStore.addRecord(newRecord)
            } catch {
                print("Ошибка сохранения записи:", error)
            }
            completedTrackers.append(newRecord)
        }
        
        for (sectionIndex, category) in visibleCategories.enumerated() {
            if let itemIndex = category.trackers.firstIndex(where: { $0.id == tracker.id }) {
                collectionView.reloadItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                break
            }
        }
    }
    
    private func weekDay(for date: Date) -> WeekDay {
        let calendar = Calendar.current
        let weekdayIndex = (calendar.component(.weekday, from: date) + 5) % 7
        return WeekDay.allCases[weekdayIndex]
    }
    
    // MARK: - NewTrackerViewControllerDelegate
    func newTrackerViewController(
        _ viewController: NewTrackerViewController,
        didCreate tracker: Tracker,
        in categoryTitle: String
    ) {
        if let existingIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
            categories[existingIndex] = TrackerCategory(
                title: categories[existingIndex].title,
                trackers: categories[existingIndex].trackers + [tracker]
            )
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let completedRecords = completedTrackers.filter { $0.trackerId == tracker.id }
        let completedCount = completedRecords.count
        let isCompletedToday = completedRecords.contains {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
        
        cell.configure(
            title: tracker.title,
            color: tracker.color,
            emoji: tracker.emoji,
            completedCount: completedCount,
            isCompletedToday: isCompletedToday
        )
        cell.buttonTapped = { [weak self] in
            self?.toggleTrackerCompletion(tracker)
        }
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.reuseIdentifier,
            for: indexPath
        ) as? CategoryHeaderView else { return UICollectionReusableView() }

        let category = visibleCategories[indexPath.section]
        header.configure(title: category.title)
        return header
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func storeDidUpdate(_ trackers: [Tracker]) {
        self.trackers = trackers
        updateVisibleTrackers()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ categories: [TrackerCategory]) {
        self.categories = categories
        updateVisibleTrackers()
    }
}

// MARK: - TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeDidUpdate(_ records: [TrackerRecord]) {
        self.completedTrackers = records
        updateVisibleTrackers()
    }
}
