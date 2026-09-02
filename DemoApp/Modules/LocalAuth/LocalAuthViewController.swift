//
//  LocalAuthViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - LocalAuthViewController
/// No view protocol: the view model is `@Observable` and this controller renders it in
/// `updateContent()`.
final class LocalAuthViewController: BaseViewModelableViewController<LocalAuthViewModelProtocol> {
    private lazy var authIcon = UIImageView(image: .init(systemName: viewModel.authIconName))
        .tintColor(.systemBlue)
        .contentMode(.scaleAspectFit)
        .setConstraints { $0.set(width: 64); $0.set(height: 64) }

    private lazy var authTypeLabel = UILabel()
        .font(.boldSystemFont(ofSize: 20))
        .textColor(.label)
        .textAlignment(.center)

    private lazy var canAuthLabel = UILabel()
        .font(.systemFont(ofSize: 14))
        .textColor(.secondaryLabel)
        .textAlignment(.center)

    private lazy var resultLabel = UILabel()
        .font(.systemFont(ofSize: 16))
        .textAlignment(.center)

    private lazy var authenticateButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Authenticate"
                $0.baseBackgroundColor = .systemBlue
                $0.cornerStyle = .capsule
                $0.image = .init(systemName: viewModel.authIconName)
                $0.imagePadding = 8
            }
    )
    .onTap { [weak self] in self?.viewModel.authenticate() }
    .setConstraints { $0.set(height: 50) }

    // MARK: - Sign in with Apple
    private lazy var appleSignInButton = AppleSignInButton()
        .with { $0.accessibilityIdentifier = "appleSignInButton" }
        .onTap { [weak self] in guard let self else { return }
            viewModel.performAppleLogin(from: self)
        }
        .setConstraints { $0.set(height: 50); $0.setWidth(to: $1.widthAnchor, multiplier: 0.8) }

    private lazy var appleResultLabel = UILabel()
        .font(.systemFont(ofSize: 12))
        .numberOfLines(0)
        .textAlignment(.center)

    private var isShowingLoading = false

    @UIViewBuilder
    override var mainView: UIView {
        VStack(
            alignment: .center,
            margins: .init(top: 40, left: 24, bottom: 40, right: 24),
            spacing: 24
        ) {
            VStack(
                alignment: .center,
                margins: .init(top: 24, left: 16, bottom: 24, right: 16),
                spacing: 12
            ) {
                authIcon
                authTypeLabel
                canAuthLabel
            }
            .backgroundColor(.secondarySystemBackground)
            .round(radius: 16)

            authenticateButton

            resultLabel

            appleSignInButton
            appleResultLabel
        }
        .setConstraints { $0.snapLeadTopTrail(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
        authTypeLabel.text(viewModel.authTypeDescription)
        canAuthLabel.text(viewModel.canAuthenticate
            ? "Biometric authentication is available"
            : "Biometric authentication is not available")
    }

    override func updateContent() {
        super.updateContent()
        renderAuthResult(viewModel.authResult)
        setLoading(viewModel.isAuthenticating)
        if let message = viewModel.appleResultMessage {
            appleResultLabel.text(message).textColor(.secondaryLabel)
        } else {
            appleResultLabel
                .text("Sign in with Apple — needs the entitlement on a real app; the demo reports the flow outcome either way")
                .textColor(.tertiaryLabel)
        }
    }

    private func renderAuthResult(_ result: Bool?) {
        guard let success = result else {
            resultLabel.text("Tap to authenticate").textColor(.tertiaryLabel)
            authIcon.image(.init(systemName: viewModel.authIconName)).tintColor(.systemBlue)
            return
        }
        let color: UIColor = success ? .systemGreen : .systemRed
        resultLabel.text(success ? "Authentication Successful" : "Authentication Failed").textColor(color)
        authIcon.image(.init(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")).tintColor(color)
    }

    private func setLoading(_ loading: Bool) {
        guard loading != isShowingLoading else { return }
        isShowingLoading = loading
        loading ? startActivityIndicator() : stopActivityIndicator()
        authenticateButton.isEnabled(!loading)
    }
}
