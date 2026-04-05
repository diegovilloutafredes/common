//
//  AlertsViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - AlertsViewController
final class AlertsViewController: BaseViewModelableViewController<AlertsViewModelProtocol> {

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
        .setConstraints { $0.set(height: 50) }
    }

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView()
            .setConstraints { $0.snap(to: $1) }
            .with { scroll in
                let contentStack = VStack(
                    margins: .init(top: 32, left: 16, bottom: 32, right: 16),
                    spacing: 16
                ) {
                    makeButton(title: "Show Snackbar", color: .systemBlue) { [weak self] in
                        Snackbar.show(.init(message: "This is a Snackbar notification"))
                        _ = self
                    }

                    makeButton(title: "Show Toast", color: .systemGreen) {
                        Toast.present(with: "This is a Toast message", duration: .medium)
                    }

                    makeButton(title: "Show System Alert", color: .systemOrange) { [weak self] in
                        self?.presentAlertView(
                            type: .customAlert(title: "Alert", message: "This is a system alert"),
                            acceptAction: nil,
                            cancelAction: nil
                        )
                    }

                    makeButton(title: "Show Activity Indicator (2s)", color: .systemPurple) { [weak self] in
                        self?.startActivityIndicator()
                        dispatchOnMainAfter(.now() + 2) { [weak self] in
                            self?.stopActivityIndicator()
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
    }
}

