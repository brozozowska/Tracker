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
}

// MARK: - NewTrackerViewController
final class NewTrackerViewController: UIViewController, NewScheduleViewControllerDelegate {

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
        static let vStackTopSpacing: CGFloat = 16
        static let actionsStackSpacing: CGFloat = 8
        
        static let emojiCollectionViewHeight: CGFloat = 204
        static let emojiLabelLeading: CGFloat = 12
        static let emojiContainerSpacing: CGFloat = 12
        static let emojiCellSize: CGSize = CGSize(width: 52, height: 52)
        static let emojiContainerTopSpacing: CGFloat = 32
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

    private lazy var nameContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = UIConstants.cornerRadius
        return view
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.font = .systemFont(ofSize: 17)
        return textField
    }()

    private lazy var optionsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = UIConstants.cornerRadius
        return view
    }()

    private lazy var categoryOption = OptionButton()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        return view
    }()
    
    private lazy var scheduleOption = OptionButton()
    
    private lazy var emojiContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIConstants.emojiContainerSpacing
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        return label
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let itemSize = UIConstants.emojiCellSize
        layout.itemSize = itemSize
        
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
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = UIConstants.cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.layer.cornerRadius = UIConstants.cornerRadius
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Public Properties
    weak var delegate: NewTrackerViewControllerDelegate?

    // MARK: - Private Properties
    private let defaultCategoryTitle = "Важное"
    private var trackerTitle: String = ""
    private let defaultColor = UIColor.systemGreen
    private let defaultEmoji = "🔥"
    private var selectedSchedule: [WeekDay] = []
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

    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая привычка"
        view.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true

        setupEmojiCollectionView()
        setupSubviews()
        setupConstraints()
        setupActions()
        
        categoryOption.setTitle("Категория")
        scheduleOption.setTitle("Расписание")
        
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
        
        vStack.setCustomSpacing(UIConstants.emojiContainerTopSpacing, after: optionsContainer)
        vStack.addArrangedSubview(emojiContainer)

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
            
            emojiLabel.leadingAnchor.constraint(equalTo: emojiContainer.leadingAnchor, constant: UIConstants.emojiLabelLeading),
            emojiCollectionView.leadingAnchor.constraint(equalTo: emojiContainer.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: emojiContainer.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: UIConstants.emojiCollectionViewHeight),

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

    @objc private func categoryTapped() { }
    
    @objc private func scheduleTapped() {
        let creator = NewScheduleViewController(selectedDays: selectedSchedule)
        creator.delegate = self
        
        let navigationController = UINavigationController(rootViewController: creator)
        navigationController.modalPresentationStyle = .pageSheet
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
        }
        
        present(navigationController, animated: true)    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard let emoji = selectedEmoji else { return }
        let tracker = Tracker(title: trackerTitle, color: defaultColor, emoji: emoji, schedule: selectedSchedule)
        delegate?.newTrackerViewController(self, didCreate: tracker, in: defaultCategoryTitle)
        dismiss(animated: true)
    }
    
    // MARK: - Private Method
    private func updateDerivedUI() {
        categoryOption.setValue(defaultCategoryTitle)
        
        scheduleOption.setValue(
            selectedSchedule.isEmpty ? nil : selectedSchedule.formattedWeekDay()
        )

        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let isValid = !trackerTitle.trimmingCharacters(in: .whitespaces).isEmpty
        && !selectedSchedule.isEmpty
        && selectedEmoji != nil
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .black : .lightGray
    }
    
    // MARK: - NewScheduleViewControllerDelegate
    func newScheduleViewController(
        _ viewController: NewScheduleViewController,
        didSelect schedule: [WeekDay]
    ) {
        self.selectedSchedule = schedule
        updateDerivedUI()
        navigationController?.popViewController(animated: true)
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
        return emojis.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
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
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let emoji = emojis[indexPath.item]
        
        if selectedEmoji == emoji {
            selectedEmoji = nil
        } else {
            selectedEmoji = emoji
        }
        
        collectionView.reloadData()
    }
}
