//
//  OptionButton.swift
//  Tracker
//
//  Created by Сергей Розов on 24.08.2025.
//

import UIKit

final class OptionButton: UIControl {
    
    // MARK: - Constants
    private enum OptionButtonStyle {
        static let chevron = UIImage(systemName: "chevron.right")
    }
    
    private enum UIConstants {
        static let cornerRadius: CGFloat = 16
        static let height: CGFloat = 75
        static let padding: CGFloat = 12
        static let stackSpacing: CGFloat = 2
        static let spacing: CGFloat = 8
    }
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()
    
    private let chevron: UIImageView = {
        let imageView = UIImageView(image: OptionButtonStyle.chevron)
        imageView.tintColor = .systemGray3
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIConstants.stackSpacing
        return stack
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = UIConstants.spacing
        return stack
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray6
        layer.cornerRadius = UIConstants.cornerRadius
        
        setupSubviews()
        setupConstraints()
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: UIConstants.height).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Layout
    private func setupSubviews() {
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(valueLabel)
        
        buttonStack.addArrangedSubview(labelsStack)
        buttonStack.addArrangedSubview(chevron)
        
        addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: topAnchor, constant: UIConstants.padding),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -UIConstants.padding),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.padding),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -UIConstants.padding)
        ])
    }
    
    // MARK: - Public Methods
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setValue(_ value: String?) {
        valueLabel.text = value
        valueLabel.isHidden = (value == nil || value?.isEmpty == true)
    }
}
