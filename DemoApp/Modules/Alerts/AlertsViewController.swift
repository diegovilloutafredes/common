//
//  AlertsViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - AlertsViewController
final class AlertsViewController: BaseViewModelableViewController<AlertsViewModelProtocol> {

    // MARK: - Inline Feedback
    private lazy var snackbarButton = makeButton(title: "Show Snackbar", color: .systemBlue) {
        Snackbar.show(.init(message: "This is a Snackbar notification"))
    }

    private lazy var toastButton = makeButton(title: "Show Toast", color: .systemGreen) {
        Toast.present(with: "This is a Toast message", duration: .medium)
    }

    private lazy var activityButton = makeButton(title: "Activity Indicator (2s)", color: .systemPurple) { [weak self] in
        self?.startActivityIndicator()
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2))
            self?.stopActivityIndicator()
        }
    }

    // MARK: - System Dialogs
    private lazy var alertButton = makeButton(title: "Show System Alert", color: .systemOrange) { [weak self] in
        self?.presentAlertView(
            type: .customAlert(title: "Alert", message: "This is a system alert dialog."),
            acceptAction: nil,
            cancelAction: nil
        )
    }

    private lazy var alertWithActionsButton = makeButton(title: "Alert with Actions", color: .systemRed) { [weak self] in
        self?.presentAlertView(
            type: .customAlert(title: "Confirm", message: "Do you want to proceed with this action?"),
            acceptAction: { _ in
                Snackbar.show(.init(message: "Action accepted"))
            },
            cancelAction: { _ in
                Toast.present(with: "Action cancelled", duration: .short)
            }
        )
    }

    // MARK: - Custom Modal Alerts
    private lazy var basicCustomAlertButton = makeButton(title: "Basic Alert (icon + confirm)", color: .systemIndigo) { [weak self] in
        self?.viewModel.onShowCustomAlertRequested(style: .basic)
    }

    private lazy var cancelCustomAlertButton = makeButton(title: "Alert with Cancel Button", color: .systemPink) { [weak self] in
        self?.viewModel.onShowCustomAlertRequested(style: .withCancel)
    }

    private lazy var mandatoryCustomAlertButton = makeButton(title: "Mandatory (no background tap)", color: .brown) { [weak self] in
        self?.viewModel.onShowCustomAlertRequested(style: .noDismissOnBackground)
    }

    private lazy var customContentAlertButton = makeButton(title: "Custom Content View", color: .systemTeal) { [weak self] in
        self?.viewModel.onShowCustomAlertRequested(style: .customContent)
    }

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                spacing: 20
            ) {
                sectionCard(
                    title: "Inline Feedback",
                    icon: "bubble.left.fill",
                    description: "Non-blocking notifications that appear briefly and dismiss automatically. Use for confirmations and status updates."
                ) {
                    VStack(spacing: 10) {
                        snackbarButton
                        toastButton
                        activityButton
                    }
                }
                sectionCard(
                    title: "System Dialogs",
                    icon: "exclamationmark.triangle.fill",
                    description: "Native UIAlertController dialogs. Blocking, modal, with optional accept and cancel actions."
                ) {
                    VStack(spacing: 10) {
                        alertButton
                        alertWithActionsButton
                    }
                }
                sectionCard(
                    title: "Custom Modal Alerts",
                    icon: "rectangle.center.inset.filled",
                    description: "CustomAlertViewController accepts any UIView as content — from the standard AlertView to fully bespoke layouts. Routed through the coordinator."
                ) {
                    VStack(spacing: 10) {
                        basicCustomAlertButton
                        cancelCustomAlertButton
                        mandatoryCustomAlertButton
                        customContentAlertButton
                    }
                }
            }.setConstraints {
                $0.snap(to: $1)
                $0.setWidth(to: $1.widthAnchor)
            }
        }.setConstraints { $0.snap(to: $1) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
    }

    private func sectionCard(
        title: String,
        icon: String,
        description: String,
        @UIViewBuilder content: () -> UIView
    ) -> UIView {
        VStack(
            margins: .init(top: 16, left: 16, bottom: 16, right: 16),
            spacing: 12
        ) {
            HStack(alignment: .center, spacing: 8) {
                UIImageView(image: .init(systemName: icon))
                    .tintColor(.label)
                    .contentMode(.scaleAspectFit)
                    .setConstraints { $0.set(width: 20); $0.set(height: 20) }
                UILabel().text(title).font(.boldSystemFont(ofSize: 18)).textColor(.label)
            }
            UILabel().text(description).font(.systemFont(ofSize: 13)).textColor(.secondaryLabel).numberOfLines(0)
            content()
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }

    private func makeButton(title: String, color: UIColor, action: @escaping Action) -> UIButton {
        UIButton(
            configuration: .filled()
                .with {
                    $0.title = title
                    $0.baseBackgroundColor = color
                    $0.cornerStyle = .capsule
                }
        )
        .onTap(action)
        .setConstraints { $0.set(height: 46) }
    }
}
