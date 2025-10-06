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
        label.text = Localizable.Categories.emptyMessage
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
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
        button.setTitle(Localizable.Categories.addButton, for: .normal)
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = UIConstants.cornerRadius
        return button
    }()
    
    private var blurView: UIVisualEffectView?
    
    // MARK: - Public Properties
    weak var delegate: CategoryListViewControllerDelegate?
    
    // MARK: - Private Properties
    private let viewModel: CategoryListViewModel
    
    // MARK: - Initializers
    init(selectedCategory: String? = nil, store: TrackerCategoryStore = TrackerCategoryStore()) {
        self.viewModel = CategoryListViewModel(store: store, selectedCategory: selectedCategory)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = Localizable.Categories.screenTitle
                
        setupTableView()
        setupSubviews()
        setupConstraints()
        setupActions()
        
        bindViewModel()
        viewModel.fetchCategories()
    }
    
    // MARK: - Setup Layout
    private func setupTableView() {
        tableView.register(ListOptionCell.self, forCellReuseIdentifier: ListOptionCell.reuseId)
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
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.refreshSelectionUI()
        }
        viewModel.onEmptyStateChanged = { [weak self] isEmpty in
            guard let self = self else { return }
            self.emptyStateImageView.isHidden = !isEmpty
            self.emptyStateLabel.isHidden = !isEmpty
            self.tableView.isHidden = isEmpty
        }
    }
    
    // MARK: - Private Methods
    private func setupActions() {
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }
    
    private func refreshSelectionUI() {
        for (index, category) in viewModel.categories.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ListOptionCell {
                let isSelected = (category.title == viewModel.selectedCategory)
                cell.setChecked(isSelected)
            }
        }
    }
    
    private func showBlur(excluding rectInView: CGRect) {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let path = UIBezierPath(rect: view.bounds)
        let holePath = UIBezierPath(roundedRect: rectInView, cornerRadius: UIConstants.cornerRadius)
        path.append(holePath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        blur.layer.mask = maskLayer
        
        blur.alpha = 0
        UIView.animate(withDuration: 0.15) { blur.alpha = 1 }
        blurView = blur
    }
    private func hideBlur() {
        guard let blur = blurView else { return }
        UIView.animate(withDuration: 0.15, animations: {
            blur.alpha = 0
        }, completion: { _ in
            blur.removeFromSuperview()
        })
        blurView = nil
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        let creator = NewCategoryViewController()
        creator.onFinish = { [weak self] newTitle in
            guard let self else { return }
            self.viewModel.addCategory(title: newTitle)
        }
        let navVC = UINavigationController(rootViewController: creator)
        present(navVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.categories.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListOptionCell.reuseId,
            for: indexPath
        ) as? ListOptionCell else { return UITableViewCell() }
        
        let category = viewModel.categories[indexPath.row]
        let isSelected = (category.title == viewModel.selectedCategory)
        cell.configure(
            title: category.title,
            isSelected: isSelected,
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == viewModel.categories.count - 1
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
        viewModel.selectCategory(at: indexPath.row)
        
        for cell in tableView.visibleCells {
            if let optionCell = cell as? ListOptionCell {
                optionCell.setChecked(false)
            }
        }
        if let selectedCell = tableView.cellForRow(at: indexPath) as? ListOptionCell {
            selectedCell.setChecked(true)
        }
        
        delegate?.newCategoryViewController(self, didSelect: viewModel.selectedCategory ?? "")
        dismiss(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let rectInTable = tableView.rectForRow(at: indexPath)
        let rectInView = tableView.convert(rectInTable, to: view)
        showBlur(excluding: rectInView)
        let title = viewModel.categories[indexPath.row].title
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            
            let edit = UIAction(title: Localizable.Actions.edit) { _ in
                self.hideBlur()
                let editor = NewCategoryViewController(initialTitle: title)
                editor.onFinish = { [weak self] newTitle in
                    guard let self else { return }
                    self.viewModel.updateCategory(oldTitle: title, newTitle: newTitle)
                }
                let nav = UINavigationController(rootViewController: editor)
                nav.modalPresentationStyle = .pageSheet
                if let sheet = nav.sheetPresentationController { sheet.detents = [.large()] }
                self.present(nav, animated: true)
            }
            
            let delete = UIAction(title: Localizable.Actions.delete, attributes: .destructive) { _ in
                self.hideBlur()
                
                BottomConfirmViewController.present(
                    from: self,
                    message: Localizable.Categories.deleteConfirm,
                    onConfirm: { [weak self] in
                        guard let self else { return }
                        let titleToDelete = self.viewModel.categories[indexPath.row].title
                        self.viewModel.deleteCategory(title: titleToDelete)
                    },
                    onCancel: { [weak self] in
                        self?.hideBlur()
                    }
                )
            }
            
            return UIMenu(children: [edit, delete])
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        animator?.addCompletion { [weak self] in
            self?.hideBlur()
        }
    }
}

// MARK: - Preview
#Preview {
    CategoryListViewController()
}
