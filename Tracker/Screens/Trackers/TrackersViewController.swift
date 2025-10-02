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
        static let searchBarTopSpacing: CGFloat = -10
        static let searchBarBottomSpacing: CGFloat = 14
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
        label.text = NSLocalizedString("trackers.empty.title", comment: "Empty state label text on trackers screen")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = NSLocalizedString("search.placeholder", comment: "Search placeholder")
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Search
    private var searchText: String = "" {
        didSet { updateVisibleTrackers() }
    }
    
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
        let creator = NewTrackerViewController(categoryStore: categoryStore)
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
        navigationItem.title = NSLocalizedString("trackers.title", comment: "Trackers screen title")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTrackerTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .label
        
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
            searchBar,
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
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.searchBarTopSpacing),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset/2),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset/2),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: UIConstants.searchBarBottomSpacing),
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
        let currentWeekDay = WeekDay(from: selectedDate)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackersForDay = category.trackers.filter { $0.schedule.contains(currentWeekDay) }
            let filtered: [Tracker]
            if query.isEmpty {
                filtered = trackersForDay
            } else {
                filtered = trackersForDay.filter { $0.title.lowercased().contains(query) }
            }
            guard !filtered.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: filtered)
        }
        
        updateEmptyStateVisibility()
        collectionView.reloadData()
    }
    
    private func updateEmptyStateVisibility() {
        let isEmpty = visibleCategories.isEmpty
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
    }
    
    private func toggleTrackerCompletion(_ tracker: Tracker) {
        guard selectedDate <= Date() else { return }

            if let record = recordStore.record(for: tracker.id, on: selectedDate) {
                try? recordStore.deleteRecord(record)
                completedTrackers.removeAll { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            } else {
                let newRecord = TrackerRecord(trackerId: tracker.id, date: Calendar.current.startOfDay(for: selectedDate))
                try? recordStore.addRecord(newRecord)
                completedTrackers.append(newRecord)
            }

            for (sectionIndex, category) in visibleCategories.enumerated() {
                if let itemIndex = category.trackers.firstIndex(where: { $0.id == tracker.id }) {
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                    collectionView.reloadItems(at: [indexPath])
                    break
                }
            }
    }
    
    private func presentDeleteTrackerConfirmation(for trackerId: UUID) {
        BottomConfirmViewController.present(
            from: self,
            message: NSLocalizedString("trackers.delete.confirm.message", comment: "Confirm tracker deletion message"),
            onConfirm: { [weak self] in
                guard let self else { return }
                do {
                    try self.trackerStore.deleteTracker(id: trackerId)
                } catch {
                    print("❌ Ошибка удаления трекера id=\(trackerId): \(error.localizedDescription)")
                }
            },
            onCancel: nil
        )
    }
    
    // MARK: - NewTrackerViewControllerDelegate
    func newTrackerViewController(
        _ viewController: NewTrackerViewController,
        didCreate tracker: Tracker,
        in categoryTitle: String
    ) {
        categories = categoryStore.fetchCategories()
        updateVisibleTrackers()
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    func newTrackerViewController(
        _ viewController: NewTrackerViewController,
        didUpdate tracker: Tracker,
        movedTo categoryTitle: String
    ) {
        categories = categoryStore.fetchCategories()
        updateVisibleTrackers()
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchText = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let categoryTitle = visibleCategories[indexPath.section].title
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            
            let edit = UIAction(title: NSLocalizedString("edit.action", comment: "Edit action title")) { _ in
                let completedCount = self.completedTrackers.filter { $0.trackerId == tracker.id }.count
                let editor = NewTrackerViewController(
                    categoryStore: self.categoryStore,
                    mode: .edit(tracker: tracker, categoryTitle: categoryTitle, completedDays: completedCount)
                )
                editor.delegate = self
                let nav = UINavigationController(rootViewController: editor)
                nav.modalPresentationStyle = .pageSheet
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.large()]
                }
                self.present(nav, animated: true)
            }
            
            let delete = UIAction(title: NSLocalizedString("delete.action", comment: "Delete action title"), attributes: .destructive) { _ in
                self.presentDeleteTrackerConfirmation(for: tracker.id)
            }
            return UIMenu(children: [edit, delete])
        }
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
