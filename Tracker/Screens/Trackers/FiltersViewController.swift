//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 03.10.2025.
//

import UIKit

// MARK: - Protocol
protocol FiltersViewControllerDelegate: AnyObject {
    func filtersViewController(_ viewController: FiltersViewController, didSelect filter: TrackerFilter)
}

// MARK: - FiltersViewController
final class FiltersViewController: UIViewController {
    
    // MARK: - UI Constants
    private enum UIConstants {
        static let topOffset: CGFloat = 24
        static let horizontalInset: CGFloat = 16
        static let rowHeight: CGFloat = 75
        static let cornerRadius: CGFloat = 16
    }
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = UIConstants.rowHeight
        table.dataSource = self
        table.delegate = self
        table.register(ListOptionCell.self, forCellReuseIdentifier: ListOptionCell.reuseId)
        return table
    }()
    
    // MARK: - State
    private let filters: [TrackerFilter] = TrackerFilter.allCases
    private var selectedFilter: TrackerFilter?
    
    // MARK: - Public Properties
    weak var delegate: FiltersViewControllerDelegate?
    
    // MARK: - Initializers
    init(selected: TrackerFilter? = nil) {
        self.selectedFilter = selected
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = NSLocalizedString("filters.title", comment: "Filters screen title")
        
        setupLayout()
    }
    
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.topOffset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { filters.count }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListOptionCell.reuseId,
            for: indexPath
        ) as? ListOptionCell else { return UITableViewCell() }
        
        let filter = filters[indexPath.row]
        let isSelected = (filter == selectedFilter)
        cell.configure(
            title: filter.title,
            isSelected: isSelected,
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == filters.count - 1
        )
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        selectedFilter = filters[indexPath.row]
        
        for cell in tableView.visibleCells {
            if let optionCell = cell as? ListOptionCell {
                optionCell.setChecked(false)
            }
        }
        if let selectedCell = tableView.cellForRow(at: indexPath) as? ListOptionCell {
            selectedCell.setChecked(true)
        }
        
        if let selectedFilter {
            delegate?.filtersViewController(self, didSelect: selectedFilter)
        }
        dismiss(animated: true)
    }
}

// MARK: - Preview
#Preview {
    FiltersViewController()
}
