//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Сергей Розов on 02.10.2025.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    
    static let reuseId = "StatisticsCell"
    
    // MARK: - UI Constants
    private enum UIConstants {
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let innerInset: CGFloat = 16
        static let vStackSpacing: CGFloat = 8
        static let outerInset: CGFloat = 6
    }
    
    // MARK: - UI Elements
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIConstants.vStackSpacing
        stack.alignment = .fill
        return stack
    }()
    
    // MARK: - Layers
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        applyGradientBorder(to: container)
    }
    
    // MARK: - Setup Methods
    private func applyGradientBorder(to view: UIView) {
        if gradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor,
                UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
                UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint   = CGPoint(x: 1, y: 0.5)
            
            let shape = CAShapeLayer()
            shape.lineWidth = UIConstants.borderWidth * 2
            shape.fillColor = UIColor.clear.cgColor
            shape.strokeColor = UIColor.black.cgColor
            gradient.mask = shape
            
            view.layer.addSublayer(gradient)
            gradientLayer = gradient
        }
        
        gradientLayer?.frame = view.bounds
        if let shape = gradientLayer?.mask as? CAShapeLayer {
            shape.path = UIBezierPath(
                roundedRect: view.bounds.insetBy(dx: UIConstants.borderWidth, dy: UIConstants.borderWidth),
                cornerRadius: UIConstants.cornerRadius
            ).cgPath
        }
    }
    
    private func setupUI() {
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(vStack)
        
        vStack.addArrangedSubview(valueLabel)
        vStack.addArrangedSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.outerInset),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.outerInset),
            
            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: UIConstants.innerInset),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: UIConstants.innerInset),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -UIConstants.innerInset),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -UIConstants.innerInset)
        ])
    }
    
    // MARK: - Configure
    func configure(title: String, value: Int) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }
}
