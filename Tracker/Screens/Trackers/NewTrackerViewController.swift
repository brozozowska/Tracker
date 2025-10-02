//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 24.08.2025.
//

import UIKit

// MARK: - Protocol
protocol NewTrackerViewControllerDelegate: AnyObject {
    func newTrackerViewController(
        _ viewController: NewTrackerViewController,
        didCreate tracker: Tracker,
        in categoryTitle: String
    )
    
    func newTrackerViewController(
        _ viewController: NewTrackerViewController,
        didUpdate tracker: Tracker,
        movedTo categoryTitle: String
    )
}

// MARK: - NewTrackerViewController
final class NewTrackerViewController: UIViewController, NewScheduleViewControllerDelegate, CategoryListViewControllerDelegate {

    // MARK: - Mode
    enum Mode {
        case create
        case edit(tracker: Tracker, categoryTitle: String, completedDays: Int)
    }

    // MARK: - Constants
    private enum UIConstants {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 24
        static let optionsDividerInset: CGFloat = 12
        static let actionsStackInset: CGFloat = 20

        static let actionButtonHeight: CGFloat = 60
        static let textFieldHeight: CGFloat = 75
        static let dividerHeight: CGFloat = 0.5

        static let cornerRadius: CGFloat = 16
        static let vStackSpacing: CGFloat = 24
        static let actionsStackSpacing: CGFloat = 8
        
        static let collectionViewHeight: CGFloat = 182
        static let collectionViewVerticalInset: CGFloat = 16
        static let collectionLabelLeading: CGFloat = 12
        static let collectionContainerSpacing: CGFloat = 12
        static let collectionCellSize: CGSize = CGSize(width: 52, height: 52)
        static let collectionContainerTopSpacing: CGFloat = 32
    }

    // MARK: - UI Elements
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIConstants.vStackSpacing
        stack.alignment = .fill
        return stack
    }()

    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    private lazy var nameContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = UIConstants.cornerRadius
        return view
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("new_tracker.name.placeholder", comment: "Placeholder for tracker name")
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = .label
        return textField
    }()

    private lazy var optionsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = UIConstants.cornerRadius
        return view
    }()

    private lazy var categoryOption = OptionButton()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var scheduleOption = OptionButton()
    
    private lazy var emojiContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIConstants.collectionContainerSpacing
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emoji.title", comment: "Emoji section title")
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        return label
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let itemSize = UIConstants.collectionCellSize
        layout.itemSize = itemSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var colorContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIConstants.collectionContainerSpacing
        stack.alignment = .fill
        return stack
    }()

    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("color.title", comment: "Color section title")
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        return label
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = UIConstants.collectionCellSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var actionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = UIConstants.actionsStackSpacing
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("cancel.action", comment: "Cancel action"), for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = UIConstants.cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("create.action", comment: "Create action"), for: .normal)
        button.layer.cornerRadius = UIConstants.cornerRadius
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Public Properties
    weak var delegate: NewTrackerViewControllerDelegate?

    // MARK: - Private Properties
    private let mode: Mode
    private var trackerToEdit: Tracker?
    private var completedDaysCount: Int = 0

    private var trackerTitle: String = ""
    private var selectedSchedule: [WeekDay] = []
    private var selectedCategory: String = ""
    
    private let emojis: [String] = [
        "🙂","😻","🌺","🐶","❤️","😱",
        "😇","😡","🥶","🤔","🙌","🍔",
        "🥦","🏓","🥇","🎸","🏝️","😪"
    ]
    
    private var selectedEmoji: String? {
        didSet {
            updateDerivedUI()
        }
    }
    
    private let colors: [UIColor] = [
        UIColor(red: 253/255, green: 76/255,  blue: 1/255,   alpha: 1.0),
        UIColor(red: 255/255, green: 136/255, blue: 30/255,  alpha: 1.0),
        UIColor(red: 0/255,   green: 123/255, blue: 250/255, alpha: 1.0),
        UIColor(red: 110/255, green: 68/255,  blue: 254/255, alpha: 1.0),
        UIColor(red: 51/255,  green: 207/255, blue: 105/255, alpha: 1.0),
        UIColor(red: 230/255, green: 109/255, blue: 212/255, alpha: 1.0),
        
        UIColor(red: 249/255, green: 212/255, blue: 212/255, alpha: 1.0),
        UIColor(red: 52/255,  green: 167/255, blue: 254/255, alpha: 1.0),
        UIColor(red: 70/255,  green: 230/255, blue: 157/255, alpha: 1.0),
        UIColor(red: 53/255,  green: 52/255,  blue: 124/255, alpha: 1.0),
        UIColor(red: 255/255, green: 103/255, blue: 77/255,  alpha: 1.0),
        UIColor(red: 255/255, green: 153/255, blue: 204/255, alpha: 1.0),
        
        UIColor(red: 246/255, green: 196/255, blue: 139/255, alpha: 1.0),
        UIColor(red: 121/255, green: 148/255, blue: 245/255, alpha: 1.0),
        UIColor(red: 131/255, green: 44/255,  blue: 241/255, alpha: 1.0),
        UIColor(red: 173/255, green: 86/255,  blue: 218/255, alpha: 1.0),
        UIColor(red: 141/255, green: 114/255, blue: 230/255, alpha: 1.0),
        UIColor(red: 47/255,  green: 208/255, blue: 88/255,  alpha: 1.0)
    ]
    
    private var selectedColor: UIColor? {
        didSet {
            updateDerivedUI()
        }
    }
    
    private let categoryStore: TrackerCategoryStore

    // MARK: - Initializers
    convenience init(categoryStore: TrackerCategoryStore) {
        self.init(categoryStore: categoryStore, mode: .create)
    }

    init(categoryStore: TrackerCategoryStore, mode: Mode) {
        self.categoryStore = categoryStore
        self.mode = mode
        super.init(nibName: nil, bundle: nil)

        if case let .edit(tracker, categoryTitle, completedDays) = mode {
            self.trackerToEdit = tracker
            self.trackerTitle = tracker.title
            self.selectedCategory = categoryTitle
            self.selectedSchedule = tracker.schedule
            self.selectedEmoji = tracker.emoji
            self.selectedColor = tracker.color
            self.completedDaysCount = completedDays
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        switch mode {
        case .create:
            navigationItem.title = NSLocalizedString("new_tracker.title", comment: "New tracker screen title")
        case .edit:
            navigationItem.title = NSLocalizedString("edit_tracker.title", comment: "Edit tracker screen title")
            vStack.insertArrangedSubview(daysLabel, at: 0)
            daysLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("tracker.days.count", comment: "Completed days count"),
                completedDaysCount
            )
            createButton.setTitle(NSLocalizedString("save.action", comment: "Save action"), for: .normal)
        }

        view.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true

        setupEmojiCollectionView()
        setupSubviews()
        setupConstraints()
        setupActions()
        
        categoryOption.setTitle(NSLocalizedString("category.title", comment: "Category option title"))
        scheduleOption.setTitle(NSLocalizedString("schedule.title", comment: "Schedule option title"))
        
        nameTextField.text = trackerTitle
        
        updateDerivedUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Setup Layout
    private func setupEmojiCollectionView() {
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(
            EmojiCell.self,
            forCellWithReuseIdentifier: EmojiCell.reuseId
        )
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(
            ColorCell.self,
            forCellWithReuseIdentifier: ColorCell.reuseId
        )

    }
    
    private func setupSubviews() {
        [
            scrollView,
            actionsStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        vStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vStack)

        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameContainer.translatesAutoresizingMaskIntoConstraints = false
        nameContainer.addSubview(nameTextField)

        vStack.addArrangedSubview(nameContainer)

        [
            categoryOption,
            divider,
            scheduleOption
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            optionsContainer.addSubview($0)
        }
        
        optionsContainer.translatesAutoresizingMaskIntoConstraints = false
        vStack.addArrangedSubview(optionsContainer)
        
        emojiContainer.addArrangedSubview(emojiLabel)
        emojiContainer.addArrangedSubview(emojiCollectionView)
        
        vStack.setCustomSpacing(UIConstants.collectionContainerTopSpacing, after: optionsContainer)
        vStack.addArrangedSubview(emojiContainer)
        
        colorContainer.addArrangedSubview(colorLabel)
        colorContainer.addArrangedSubview(colorCollectionView)
        
        vStack.setCustomSpacing(UIConstants.collectionContainerTopSpacing / 2, after: emojiContainer)
        vStack.addArrangedSubview(colorContainer)

        [
            cancelButton,
            createButton
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        actionsStack.addArrangedSubview(cancelButton)
        actionsStack.addArrangedSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: actionsStack.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),

            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.verticalInset),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.horizontalInset),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.horizontalInset),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.verticalInset),

            nameContainer.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            nameTextField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: UIConstants.horizontalInset),
            nameTextField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -UIConstants.horizontalInset),
            nameTextField.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),

            categoryOption.topAnchor.constraint(equalTo: optionsContainer.topAnchor),
            categoryOption.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            categoryOption.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),

            divider.topAnchor.constraint(equalTo: categoryOption.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor, constant: UIConstants.optionsDividerInset),
            divider.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor, constant: -UIConstants.optionsDividerInset),
            divider.heightAnchor.constraint(equalToConstant: UIConstants.dividerHeight),

            scheduleOption.topAnchor.constraint(equalTo: divider.bottomAnchor),
            scheduleOption.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            scheduleOption.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            scheduleOption.bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor),
            
            emojiLabel.leadingAnchor.constraint(equalTo: emojiContainer.leadingAnchor, constant: UIConstants.collectionLabelLeading),
            emojiCollectionView.leadingAnchor.constraint(equalTo: emojiContainer.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: emojiContainer.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: UIConstants.collectionViewHeight),
            
            colorLabel.leadingAnchor.constraint(equalTo: colorContainer.leadingAnchor, constant: UIConstants.collectionLabelLeading),
            colorCollectionView.leadingAnchor.constraint(equalTo: colorContainer.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: colorContainer.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: UIConstants.collectionViewHeight),

            actionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.actionsStackInset),
            actionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.actionsStackInset),
            actionsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.actionsStackInset),
            
            cancelButton.heightAnchor.constraint(equalToConstant: UIConstants.actionButtonHeight),
            createButton.heightAnchor.constraint(equalToConstant: UIConstants.actionButtonHeight)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        categoryOption.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        scheduleOption.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }

    @objc private func nameChanged(_ sender: UITextField) {
        trackerTitle = sender.text ?? ""
        updateDerivedUI()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func categoryTapped() {
        let creator = CategoryListViewController(selectedCategory: selectedCategory.isEmpty ? nil : selectedCategory)
        creator.delegate = self
        let navigationController = UINavigationController(rootViewController: creator)
        navigationController.modalPresentationStyle = .pageSheet
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
        }
        present(navigationController, animated: true)
    }
    
    @objc private func scheduleTapped() {
        let creator = NewScheduleViewController(selectedDays: selectedSchedule)
        creator.delegate = self
        
        let navigationController = UINavigationController(rootViewController: creator)
        navigationController.modalPresentationStyle = .pageSheet
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
        }
        
        present(navigationController, animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard
            let emoji = selectedEmoji,
            let color = selectedColor
        else { return }
        
        switch mode {
        case .create:
            let tracker = Tracker(title: trackerTitle, color: color, emoji: emoji, schedule: selectedSchedule)
            let categoryTitle = selectedCategory
            
            do {
                try categoryStore.addTracker(tracker, toCategoryWithTitle: categoryTitle)
                
                delegate?.newTrackerViewController(
                    self,
                    didCreate: tracker,
                    in: categoryTitle
                )
                
                presentingViewController?.dismiss(animated: true)
            } catch {
                print("Ошибка сохранения трекера: \(error)")
            }
        case .edit:
            guard let original = trackerToEdit else { return }
            let updated = Tracker(
                id: original.id,
                title: trackerTitle,
                color: color,
                emoji: emoji,
                schedule: selectedSchedule
            )
            let categoryTitle = selectedCategory
            do {
                try categoryStore.addTracker(updated, toCategoryWithTitle: categoryTitle)
                delegate?.newTrackerViewController(self, didUpdate: updated, movedTo: categoryTitle)
                presentingViewController?.dismiss(animated: true)
            } catch {
                print("Ошибка обновления трекера: \(error)")
            }
        }
    }
    
    // MARK: - Private Method
    private func updateDerivedUI() {
        categoryOption.setValue(selectedCategory.isEmpty ? "" : selectedCategory)
        
        scheduleOption.setValue(
            selectedSchedule.isEmpty ? nil : selectedSchedule.formattedWeekDay()
        )

        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let isValid = !trackerTitle.trimmingCharacters(in: .whitespaces).isEmpty
        && !selectedCategory.isEmpty
        && !selectedSchedule.isEmpty
        && selectedEmoji != nil
        && selectedColor != nil
        
        createButton.isEnabled = isValid
        if isValid {
            createButton.backgroundColor = .label
            createButton.setTitleColor(.systemBackground, for: .normal)
        } else {
            createButton.backgroundColor = .lightGray
            createButton.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: - NewScheduleViewControllerDelegate
    func newScheduleViewController(
        _ viewController: NewScheduleViewController,
        didSelect schedule: [WeekDay]
    ) {
        self.selectedSchedule = schedule
        updateDerivedUI()
        viewController.dismiss(animated: true)
    }
    
    // MARK: - CategoryListViewControllerDelegate
    func newCategoryViewController(
        _ viewController: CategoryListViewController,
        didSelect category: String
    ) {
        self.selectedCategory = category
        updateDerivedUI()
        viewController.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch collectionView {
        case emojiCollectionView:
            return emojis.count
        case colorCollectionView:
            return colors.count
        default:
            return 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch collectionView {
        case emojiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseId,
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji)
            cell.backgroundColor = (emoji == selectedEmoji) ? UIColor.systemGray4 : .clear
            cell.layer.cornerRadius = UIConstants.cornerRadius
            cell.layer.masksToBounds = true
            
            return cell
            
        case colorCollectionView:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseId,
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            
            let color = colors[indexPath.item]
            cell.configure(with: color, isSelected: color == selectedColor)
            return cell
        
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch collectionView {
        case emojiCollectionView:
            let emoji = emojis[indexPath.item]
            selectedEmoji = (selectedEmoji == emoji) ? nil : emoji
        case colorCollectionView:
            let color = colors[indexPath.item]
            selectedColor = (selectedColor == color) ? nil : color
        default:
            break
        }
        collectionView.reloadData()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: UIConstants.collectionViewVerticalInset,
            left: 0,
            bottom: UIConstants.collectionViewVerticalInset,
            right: 0
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return UIConstants.collectionCellSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        let numberOfItemsPerRow: CGFloat = 6
        let totalCellWidth = numberOfItemsPerRow * UIConstants.collectionCellSize.width
        let totalSpacing = collectionView.bounds.width - totalCellWidth
        let spacing = totalSpacing / (numberOfItemsPerRow - 1)
        return max(spacing, 0)
    }
}
