//
//  EmojiCell.swift
//  Tracker
//
//  Created by Сергей Розов on 29.08.2025.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    
    // MARK: - Constants
    static let reuseId = "EmojiCell"
    
    // MARK: - UI Elements
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}
