//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 19.09.2025.
//

import UIKit

// MARK: - Protocol
protocol CategoryListViewControllerDelegate: AnyObject {
    func newCategoryViewController(
        _ viewController: CategoryListViewController,
        didSelect category: String
    )
}

// MARK: - CategoryListViewController
final class CategoryListViewController: UIViewController {
    
    // MARK: - Constants
    private enum UIConstants {
        static let TopOffset: CGFloat = 24
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 16
        static let rowHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let cornerRadius: CGFloat = 16
        
        static let emptyImageSize: CGFloat = 80
        static let emptyLabelSpacing: CGFloat = 8
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
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UIConstants.rowHeight
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = UIConstants.cornerRadius
        return button
    }()
    
    // MARK: - Public Properties
    weak var delegate: CategoryListViewControllerDelegate?
    
    // MARK: - Private Properties
    private let categoryStore = TrackerCategoryStore()
    private var categories: [TrackerCategory] = []
    private var selectedCategory: String?
    
    // MARK: - Initializers
    init(selectedCategory: String? = nil) {
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Категория"
                
        setupTableView()
        setupSubviews()
        setupConstraints()
        setupActions()
        
        categoryStore.delegate = self
        categories = categoryStore.fetchCategories()
        tableView.reloadData()
        updateEmptyStateVisibility()
    }
    
    // MARK: - Setup Layout
    private func setupTableView() {
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupSubviews() {
        [
            tableView,
            doneButton,
            emptyStateImageView,
            emptyStateLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: UIConstants.emptyImageSize),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: UIConstants.emptyImageSize),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: UIConstants.emptyLabelSpacing),
            
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
    
    private func updateEmptyStateVisibility() {
        let isEmpty = categories.isEmpty
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        let creator = NewCategoryViewController()
        creator.onFinish = { [weak self] newTitle in
            guard let self = self else { return }
            self.selectedCategory = newTitle
            if self.categories.first(where: { $0.title == newTitle }) == nil {
                self.categories.append(TrackerCategory(title: newTitle, trackers: []))
                self.categories.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            }
            self.tableView.reloadData()
            self.updateEmptyStateVisibility()
            self.delegate?.newCategoryViewController(self, didSelect: newTitle)
        }
        let nav = UINavigationController(rootViewController: creator)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
        }
        present(nav, animated: true)
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryListViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ categories: [TrackerCategory]) {
        self.categories = categories
        tableView.reloadData()
        updateEmptyStateVisibility()
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        categories.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseId,
            for: indexPath
        ) as? CategoryCell else { return UITableViewCell() }
        
        let title = categories[indexPath.row].title
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == categories.count - 1
        let isSelected = (title == selectedCategory)
        
        cell.configure(
            day: title,
            isSelected: isSelected,
            isFirst: isFirst,
            isLast: isLast
        )
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let newTitle = categories[indexPath.row].title
        selectedCategory = newTitle
        
        for cell in tableView.visibleCells {
            if let categoryCell = cell as? CategoryCell {
                categoryCell.setChecked(false)
            }
        }
        if let selectedCell = tableView.cellForRow(at: indexPath) as? CategoryCell {
            selectedCell.setChecked(true)
        }
        
        delegate?.newCategoryViewController(self, didSelect: newTitle)
        dismiss(animated: true)
    }
}

#Preview {
    let viewController = CategoryListViewController()
    return viewController
}
