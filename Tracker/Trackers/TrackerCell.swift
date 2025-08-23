//
//  TrackerCell.swift
//  Tracker
//
//  Created by Сергей Розов on 19.08.2025.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Constants
    static let reuseIdentifier = "TrackerCell"
    
    private enum ActionButtonStyle {
        private static let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        static let checkmark = UIImage(systemName: "checkmark", withConfiguration: config)
        static let plus = UIImage(systemName: "plus", withConfiguration: config)
    }
    
    private enum UIConstants {
        static let cornerRadius: CGFloat = 16
        static let buttonSize: CGFloat = 32
        static let spacing: CGFloat = 6
    }
    
    // MARK: - UI Elements
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.layer.cornerRadius = UIConstants.cornerRadius
        return button
    }()
    
    // MARK: - Public Properties
    var buttonTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = UIConstants.cornerRadius
        
        setupSubviews()
        setupConstraints()
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func didTapActionButton() {
        buttonTapped?()
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        [
            countLabel,
            actionButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: UIConstants.spacing),
            actionButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonSize),
            actionButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonSize)
        ])
    }
    
    // MARK: - Public Methods
    func configure(completedCount: Int = 0, isCompletedToday: Bool) {
        countLabel.text = "Выполнено: \(completedCount)"
        updateButtonStyle(isCompleted: isCompletedToday)
    }
    
    // MARK: - Private Methods
    private func updateButtonStyle(isCompleted: Bool) {
        if isCompleted {
            actionButton.setImage(ActionButtonStyle.checkmark, for: .normal)
            actionButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
        } else {
            actionButton.setImage(ActionButtonStyle.plus, for: .normal)
            actionButton.backgroundColor = UIColor.systemGreen
        }
    }
}
