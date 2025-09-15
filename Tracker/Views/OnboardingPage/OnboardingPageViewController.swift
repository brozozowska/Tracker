//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 15.09.2025.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Private Properties
    private let backgroundImage: UIImage
    private let text: String
    
    // MARK: - UI Elements
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializers
    init(backgroundImage: UIImage, text: String) {
        self.backgroundImage = backgroundImage
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupLayout()
    }
    
    // MARK: - Setup Methods
    private func addSubviews() {
        [backgroundImageView, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -320),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
