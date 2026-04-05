//
//  LocalAuthViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - LocalAuthViewController
final class LocalAuthViewController: BaseViewModelableViewController<LocalAuthViewModelProtocol> {
    private lazy var authTypeLabel = UILabel()
        .font(.systemFont(ofSize: 16))
        .textColor(.label)
        .numberOfLines(0)

    private lazy var canAuthLabel = UILabel()
        .font(.systemFont(ofSize: 16))
        .textColor(.label)

    private lazy var resultLabel = UILabel()
        .text("Result: Pending")
        .font(.boldSystemFont(ofSize: 18))
        .textColor(.secondaryLabel)
        .textAlignment(.center)

    private lazy var authenticateButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Authenticate"
                $0.baseBackgroundColor = .systemBlue
                $0.cornerStyle = .capsule
            }
    )
    .onTap { [weak self] in self?.authenticate() }
    .setConstraints { $0.set(height: 50) }

    @UIViewBuilder
    override var mainView: UIView {
        VStack(
            alignment: .center,
            margins: .init(top: 40, left: 24, bottom: 40, right: 24),
            spacing: 24
        ) {
            VStack(
                margins: .init(top: 16, left: 16, bottom: 16, right: 16),
                spacing: 12
            ) {
                authTypeLabel
                canAuthLabel
            }
            .backgroundColor(.secondarySystemBackground)
            .round(radius: 12)

            authenticateButton

            resultLabel
        }
        .setConstraints { $0.snap(to: $1) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
        authTypeLabel.text("Authentication Type: \(viewModel.authTypeDescription)")
        canAuthLabel.text("Can Authenticate: \(viewModel.canAuthenticate ? "Yes" : "No")")
    }

    private func authenticate() {
        viewModel.authenticate { [weak self] success in
            guard let self else { return }
            let text = success ? "Result: Success" : "Result: Failed"
            let color: UIColor = success ? .systemGreen : .systemRed
            resultLabel.text(text).textColor(color)
        }
    }
}
