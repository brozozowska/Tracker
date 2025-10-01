//
//  CategoryCell.swift
//  Tracker
//
//  Created by Сергей Розов on 19.09.2025.
//

import UIKit

final class CategoryCell: UITableViewCell {
    
    // MARK: - Constants
    static let reuseId = "CategoryCell"
    
    private enum UIConstants {
        static let cornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let dividerHeight: CGFloat = 0.5
        static let checkmarkSize: CGFloat = 20
    }
    
    // MARK: - UI Elements
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        return label
    }()
    
    private lazy var checkmarkView: UIImageView = {
        let image = UIImage(systemName: "checkmark")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        [
            titleLabel,
            checkmarkView,
            divider
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.horizontalPadding),
            
            checkmarkView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.horizontalPadding),
            checkmarkView.widthAnchor.constraint(equalToConstant: UIConstants.checkmarkSize),
            checkmarkView.heightAnchor.constraint(equalToConstant: UIConstants.checkmarkSize),
            
            divider.heightAnchor.constraint(equalToConstant: UIConstants.dividerHeight),
            divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.horizontalPadding),
            divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.horizontalPadding),
            divider.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func configure(day: String, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        titleLabel.text = day

        containerView.layer.cornerRadius = UIConstants.cornerRadius
        containerView.layer.maskedCorners = []

        if isFirst {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if isLast {
            containerView.layer.maskedCorners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }

        divider.isHidden = isLast
        checkmarkView.isHidden = !isSelected
    }
    
    func setChecked(_ checked: Bool) {
        checkmarkView.isHidden = !checked
    }
}
