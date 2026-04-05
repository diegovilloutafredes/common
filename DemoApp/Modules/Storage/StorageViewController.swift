//
//  StorageViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - StorageViewController
final class StorageViewController: BaseViewModelableViewController<StorageViewModelProtocol> {
    private lazy var udValueLabel = statusLabel(text: "Not saved")
    private lazy var fileValueLabel = statusLabel(text: "Not saved")
    private lazy var keychainValueLabel = statusLabel(text: "Not saved")

    private func statusLabel(text: String) -> UILabel {
        UILabel()
            .text(text)
            .font(.systemFont(ofSize: 13))
            .textColor(.secondaryLabel)
            .numberOfLines(2)
    }

    private func makeButton(title: String, color: UIColor, action: @escaping () -> Void) -> UIButton {
        UIButton(
            configuration: .filled()
                .with {
                    $0.title = title
                    $0.baseBackgroundColor = color
                    $0.cornerStyle = .capsule
                }
        )
        .onTap(action)
        .setConstraints { $0.set(height: 44) }
    }

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView()
            .setConstraints { $0.snap(to: $1) }
            .with { scroll in
                let contentStack = VStack(
                    margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                    spacing: 16
                ) {
                    // UserDefaults section
                    sectionCard(
                        headerText: "UserDefaults",
                        button: makeButton(title: "Save to UserDefaults", color: .systemBlue) { [weak self] in
                            self?.viewModel.saveToUserDefaults(value: "Hello UserDefaults")
                            self?.refreshLabels()
                            Snackbar.show(.init(message: "Saved to UserDefaults"))
                        },
                        statusLabel: udValueLabel
                    )

                    // File section
                    sectionCard(
                        headerText: "FileStorage",
                        button: makeButton(title: "Save to File", color: .systemGreen) { [weak self] in
                            self?.viewModel.saveToFile(value: "Hello FileStorage")
                            self?.refreshLabels()
                            Snackbar.show(.init(message: "Saved to FileStorage"))
                        },
                        statusLabel: fileValueLabel
                    )

                    // Keychain section
                    sectionCard(
                        headerText: "Keychain",
                        button: makeButton(title: "Save to Keychain", color: .systemPurple) { [weak self] in
                            self?.viewModel.saveToKeychain(value: "Hello Keychain")
                            self?.refreshLabels()
                            Snackbar.show(.init(message: "Saved to Keychain"))
                        },
                        statusLabel: keychainValueLabel
                    )

                    // Actions
                    HStack(spacing: 12) {
                        makeButton(title: "Read All", color: .systemOrange) { [weak self] in
                            self?.refreshLabels()
                        }
                        makeButton(title: "Clear All", color: .systemRed) { [weak self] in
                            self?.viewModel.clearAll()
                            self?.refreshLabels()
                            Snackbar.show(.init(message: "All cleared"))
                        }
                    }
                }
                contentStack.translatesAutoresizingMaskIntoConstraints = false
                scroll.addSubview(contentStack)
                NSLayoutConstraint.activate([
                    contentStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
                    contentStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
                    contentStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
                    contentStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
                    contentStack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
                ])
            }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
        refreshLabels()
    }

    private func sectionCard(headerText: String, button: UIButton, statusLabel: UILabel) -> UIView {
        VStack(
            margins: .init(top: 12, left: 12, bottom: 12, right: 12),
            spacing: 8
        ) {
            UILabel()
                .text(headerText)
                .font(.boldSystemFont(ofSize: 16))
                .textColor(.label)
            button
            statusLabel
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }

    private func refreshLabels() {
        let results = viewModel.readAll()
        udValueLabel.text(results.userDefaults.map { "Saved: \($0.value)" } ?? "Not saved")
        fileValueLabel.text(results.file.map { "Saved: \($0.value)" } ?? "Not saved")
        keychainValueLabel.text(results.keychain.map { "Saved: \($0.value)" } ?? "Not saved")
    }
}
