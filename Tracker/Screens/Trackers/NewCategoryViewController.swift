//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 19.09.2025.
//

import UIKit

final class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    private enum UIConstants {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 24
        static let textFieldHeight: CGFloat = 75
        static let cornerRadius: CGFloat = 16
        static let actionButtonHeight: CGFloat = 60
    }
    
    var onFinish: ((String) -> Void)?
    
    private let categoryStore = TrackerCategoryStore()
    
    private lazy var nameContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = UIConstants.cornerRadius
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.font = .systemFont(ofSize: 17)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = UIConstants.cornerRadius
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая категория"
        
        setupSubviews()
        setupConstraints()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupSubviews() {
        [nameContainer, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameContainer.addSubview(nameTextField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.verticalInset),
            nameContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset),
            nameContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset),
            nameContainer.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            
            nameTextField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: UIConstants.horizontalInset),
            nameTextField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -UIConstants.horizontalInset),
            nameTextField.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.verticalInset),
            doneButton.heightAnchor.constraint(equalToConstant: UIConstants.actionButtonHeight)
        ])
    }
    
    @objc private func textChanged() {
        let trimmed = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let enabled = !trimmed.isEmpty
        doneButton.isEnabled = enabled
        doneButton.backgroundColor = enabled ? .black : .lightGray
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func doneTapped() {
        let trimmed = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        do {
            let category = TrackerCategory(title: trimmed, trackers: [])
            try categoryStore.addNewCategory(category)
        } catch {
            print("❌ Не удалось сохранить категорию '\(trimmed)': \(error.localizedDescription)")
        }
        
        onFinish?(trimmed)
        dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneTapped()
        return true
    }
}
