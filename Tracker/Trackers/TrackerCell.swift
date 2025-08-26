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
        static let colorViewHeight: CGFloat = 90

        static let circleSize: CGFloat = 24
        static let circleTopInset: CGFloat = 12
        static let circleLeftInset: CGFloat = 12
                
        static let titleLeftInset: CGFloat = 12
        static let titleRightInset: CGFloat = 12
        static let titleBottomInset: CGFloat = 12
        
        static let buttonSize: CGFloat = 34
        static let buttonTopSpacing: CGFloat = 16
        static let buttonRightInset: CGFloat = 12
        
        static let countLabelLeftInset: CGFloat = 12
    }
    
    // MARK: - UI Elements
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        view.layer.cornerRadius = UIConstants.circleSize / 2
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.layer.cornerRadius = UIConstants.buttonSize / 2
        return button
    }()
    
    // MARK: - Public Properties
    var buttonTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
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
            colorView,
            countLabel,
            actionButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [
            circleView,
            titleLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            colorView.addSubview($0)
        }
        
        circleView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: UIConstants.colorViewHeight),
            
            circleView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: UIConstants.circleTopInset),
            circleView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: UIConstants.circleLeftInset),
            circleView.widthAnchor.constraint(equalToConstant: UIConstants.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: UIConstants.circleSize),
            
            emojiLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: UIConstants.titleLeftInset),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -UIConstants.titleRightInset),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -UIConstants.titleBottomInset),
            
            actionButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: UIConstants.buttonTopSpacing),
            actionButton.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -UIConstants.buttonRightInset),
            actionButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonSize),
            actionButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonSize),
            
            countLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: UIConstants.countLabelLeftInset),
        ])
    }
    
    // MARK: - Public Methods
    func configure(
        title: String,
        color: UIColor,
        emoji: String,
        completedCount: Int = 0,
        isCompletedToday: Bool
    ) {
        titleLabel.text = title
        colorView.backgroundColor = color
        emojiLabel.text = emoji
        countLabel.text = "\(completedCount) \(dayWord(for: completedCount))"
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
    
    private func dayWord(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder100 >= 11 && remainder100 <= 14 {
            return "дней"
        }
        
        switch remainder10 {
        case 1:
            return "день"
        case 2...4:
            return "дня"
        default:
            return "дней"
        }
    }
}
