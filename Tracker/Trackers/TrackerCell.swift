//
//  TrackerCell.swift
//  Tracker
//
//  Created by Сергей Розов on 19.08.2025.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    
    // MARK: - UI Elements
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Public Properties
    var buttonTapped: ((Tracker) -> Void)?
    
    // MARK: - Private Properties
    private var tracker: Tracker?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 16
        
        setupSubviews()
        setupConstraints()
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
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
            actionButton.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 6),
            actionButton.widthAnchor.constraint(equalToConstant: 32),
            actionButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, completedCount: Int = 0, isCompletedToday: Bool) {
        self.tracker = tracker
        countLabel.text = "Выполнено: \(completedCount)"
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let symbolName = isCompletedToday ? "checkmark" : "plus"
        let image = UIImage(systemName: symbolName, withConfiguration: config)
        actionButton.setImage(image, for: .normal)
        actionButton.tintColor = .white
        actionButton.backgroundColor = isCompletedToday ? UIColor.systemGreen.withAlphaComponent(0.3) : UIColor.systemGreen
    }
    
    // MARK: - Actions
    @objc private func didTapActionButton() {
        guard let tracker = tracker else { return }
        buttonTapped?(tracker)
    }
}
