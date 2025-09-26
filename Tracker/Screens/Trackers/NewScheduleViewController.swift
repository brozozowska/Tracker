//
//  NewScheduleViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 25.08.2025.
//

import UIKit

// MARK: - Protocol
protocol NewScheduleViewControllerDelegate: AnyObject {
    func newScheduleViewController(
        _ viewController: NewScheduleViewController,
        didSelect schedule: [WeekDay],
    )
}

// MARK: - NewScheduleViewController
final class NewScheduleViewController: UIViewController {
    // MARK: - Constants
    private enum UIConstants {
        static let TopOffset: CGFloat = 24
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 16
        static let rowHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let cornerRadius: CGFloat = 16
    }
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .clear
        tableView.rowHeight = UIConstants.rowHeight
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("done.action", comment: "Done button title"), for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = UIConstants.cornerRadius
        return button
    }()

    // MARK: - Public Properties
    weak var delegate: NewScheduleViewControllerDelegate?
    
    // MARK: - Private Properties
    private var selectedSchedule: [WeekDay]
    private let dayNames = WeekDay.allCases

    // MARK: - Initializers
    init(selectedDays: [WeekDay]) {
        self.selectedSchedule = selectedDays
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = NSLocalizedString("schedule.title", comment: "Schedule screen title")
        
        setupTableView()
        setupSubviews()
        setupConstraints()
        setupActions()
    }

    // MARK: - Setup Layout
    private func setupTableView() {
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseId)
        tableView.dataSource = self
    }
    
    private func setupSubviews() {
        [
            tableView,
            doneButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.TopOffset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -UIConstants.verticalInset),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.verticalInset),
            doneButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonHeight)
        ])
    }
    
    private func setupActions() {
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        delegate?.newScheduleViewController(self, didSelect: selectedSchedule)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NewScheduleViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        dayNames.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.reuseId,
            for: indexPath
        ) as? ScheduleCell else { return UITableViewCell() }
        
        let day = dayNames[indexPath.row]
        cell.configure(
            day: day.longName,
            isOn: selectedSchedule.contains(day),
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == dayNames.count - 1
        )
        cell.switchChanged = { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                self.selectedSchedule.append(day)
            } else {
                self.selectedSchedule.removeAll { $0 == day }
            }
        }
        return cell
    }
}
