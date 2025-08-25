//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Сергей Розов on 25.08.2025.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    
    // MARK: - Constants
    static let reuseId = "ScheduleCell"
    
    private enum UIConstants {
        static let cornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let dividerHeight: CGFloat = 0.5
    }

    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        return label
    }()
    
    private let toggle: UISwitch = {
        let toggle = UISwitch()
        return toggle
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    // MARK: - Public Properties
    var switchChanged: ((Bool) -> Void)?

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        setupSubviews()
        setupConstraints()
        toggle.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
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
            toggle,
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
            
            toggle.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.horizontalPadding),
            
            divider.heightAnchor.constraint(equalToConstant: UIConstants.dividerHeight),
            divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.horizontalPadding),
            divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.horizontalPadding),
            divider.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func configure(day: String, isOn: Bool, isFirst: Bool, isLast: Bool) {
        titleLabel.text = day
        toggle.isOn = isOn

        containerView.layer.cornerRadius = UIConstants.cornerRadius
        containerView.layer.maskedCorners = []

        if isFirst {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if isLast {
            containerView.layer.maskedCorners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }

        divider.isHidden = isLast
    }

    // MARK: - Actions
    @objc private func switchValueChanged() {
        switchChanged?(toggle.isOn)
    }
}
