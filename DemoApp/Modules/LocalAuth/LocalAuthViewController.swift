//
//  LocalAuthViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - LocalAuthViewProtocol
protocol LocalAuthViewProtocol: AnyObject {
    func updateResult(success: Bool)
    func showLoading()
    func hideLoading()
}

// MARK: - LocalAuthViewController
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
        .text("Tap to authenticate")
        .font(.systemFont(ofSize: 16))
        .textColor(.tertiaryLabel)
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
        }
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
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
}

// MARK: - LocalAuthViewProtocol
extension LocalAuthViewController: LocalAuthViewProtocol {
    func updateResult(success: Bool) {
        let text = success ? "Authentication Successful" : "Authentication Failed"
        let color: UIColor = success ? .systemGreen : .systemRed
        let icon = success ? "checkmark.circle.fill" : "xmark.circle.fill"
        resultLabel.text(text).textColor(color)
        authIcon.image(.init(systemName: icon)).tintColor(color)
    }

    func showLoading() {
        startActivityIndicator()
        authenticateButton.isEnabled(false)
    }

    func hideLoading() {
        stopActivityIndicator()
        authenticateButton.isEnabled(true)
    }
}
