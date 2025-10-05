//
//  BottomConfirmViewController.swift
//  Tracker
//
//  Created by Сергей Розов on 21.09.2025.
//

import UIKit

final class BottomConfirmViewController: UIViewController {

    // MARK: - UI Constants
    private enum UIConstants {
        static let horizontalInset: CGFloat = 8
        static let cornerRadius: CGFloat = 16
        static let messageTopInset: CGFloat = 14
        static let messageBottomInset: CGFloat = 14
        static let dividerHeight: CGFloat = 0.5
        static let actionButtonHeight: CGFloat = 61
        static let cancelButtonTopSpacing: CGFloat = 8
        static let contentBottomInset: CGFloat = 8
        static let backgroundDimAlpha: CGFloat = 0.4
        static let confirmAlpha: CGFloat = 0.8
        static let presentDuration: TimeInterval = 0.15
        static let dismissDuration: TimeInterval = 0.15
    }
    
    // MARK: - UI Elements
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(UIConstants.backgroundDimAlpha)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = UIConstants.cancelButtonTopSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var confirmContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .secondarySystemBackground : UIColor.white.withAlphaComponent(UIConstants.confirmAlpha)
        }
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("delete.action", comment: "Delete action title"), for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("cancel.action", comment: "Cancel action title"), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
        button.layer.cornerRadius = UIConstants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Public Properties
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - Private Properties
    private let message: String

    // MARK: - Initializers
    init(message: String = NSLocalizedString("delete_category.confirm_message", comment: "Default confirm message for deleting category")) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(dimView)
        view.addSubview(contentStack)

        messageLabel.text = message

        confirmContainer.addSubview(messageLabel)
        confirmContainer.addSubview(divider)
        confirmContainer.addSubview(confirmButton)

        contentStack.addArrangedSubview(confirmContainer)
        contentStack.addArrangedSubview(cancelButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInset),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInset),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.contentBottomInset),

            messageLabel.topAnchor.constraint(equalTo: confirmContainer.topAnchor, constant: UIConstants.messageTopInset),
            messageLabel.leadingAnchor.constraint(equalTo: confirmContainer.leadingAnchor, constant: UIConstants.horizontalInset),
            messageLabel.trailingAnchor.constraint(equalTo: confirmContainer.trailingAnchor, constant: -UIConstants.horizontalInset),

            divider.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: UIConstants.messageBottomInset),
            divider.leadingAnchor.constraint(equalTo: confirmContainer.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: confirmContainer.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: UIConstants.dividerHeight),

            confirmButton.topAnchor.constraint(equalTo: divider.bottomAnchor),
            confirmButton.leadingAnchor.constraint(equalTo: confirmContainer.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: confirmContainer.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: UIConstants.actionButtonHeight),
            confirmButton.bottomAnchor.constraint(equalTo: confirmContainer.bottomAnchor),

            cancelButton.heightAnchor.constraint(equalToConstant: UIConstants.actionButtonHeight)
        ])
    }

    // MARK: - Animations
    private func animateIn() {
        contentStack.transform = CGAffineTransform(translationX: 0, y: 80)
        UIView.animate(withDuration: UIConstants.presentDuration, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1
            self.contentStack.transform = .identity
        }
    }

    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: UIConstants.dismissDuration, delay: 0, options: [.curveEaseIn], animations: {
            self.dimView.alpha = 0
            self.contentStack.transform = CGAffineTransform(translationX: 0, y: 80)
        }, completion: { _ in
            completion?()
        })
    }

    // MARK: - Actions
    @objc private func confirmTapped() {
        let confirm = onConfirm
        dismissAnimated { confirm?() }
    }

    @objc private func cancelTapped() {
        let cancel = onCancel
        dismissAnimated { cancel?() }
    }

    private func dismissAnimated(_ completion: (() -> Void)? = nil) {
        animateOut { [weak self] in
            self?.dismiss(animated: false, completion: completion)
        }
    }
}

// MARK: - Convenience
extension BottomConfirmViewController {
    static func present(
        from presenter: UIViewController,
        message: String,
        onConfirm: (() -> Void)?,
        onCancel: (() -> Void)? = nil
    ) {
        let viewController = BottomConfirmViewController(
            message: message
        )
        viewController.onConfirm = onConfirm
        viewController.onCancel = onCancel
        presenter.present(viewController, animated: false)
    }
}

// MARK: - Preview
#Preview {
    BottomConfirmViewController()
}
