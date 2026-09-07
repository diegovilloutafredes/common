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

    private lazy var actionSnackbarButton = makeButton(title: "Snackbar with Action", color: .systemCyan) {
        Snackbar.show(.init(
            message: "Message archived",
            actionTitle: "Undo",
            onAction: { Toast.present(with: "Undone ✓", duration: .short) },
            onDismiss: { Logger.log("Snackbar dismissed") }
        ))
    }

    // MARK: - Sheet with detents
    private lazy var detentsSheetButton = makeButton(title: "Sheet with Detents", color: .systemMint) { [weak self] in
        guard let self else { return }
        let sheet = UIViewController()
            .with { $0.view.backgroundColor = .systemBackground }
        VStack(alignment: .center, margins: .init(all: 24), spacing: 12) {
            UILabel().text("Detents sheet").font(.boldSystemFont(ofSize: 20)).textColor(.label)
            UILabel()
                .text("Opens at .medium, drag up for .large — configured with the sheetPresentationController detents chainable.")
                .font(.systemFont(ofSize: 14))
                .textColor(.secondaryLabel)
                .numberOfLines(0)
                .textAlignment(.center)
        }.with { sheet.view.addSubview($0) }
            .setConstraints { $0.snapLeadTopTrail(to: $1.safeAreaLayoutGuide) }
        sheet.sheetPresentationController?
            .detents([.medium(), .large()])
        present(sheet, animated: true)
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
        self?.viewModel.showCustomAlert(style: .basic)
    }

    private lazy var cancelCustomAlertButton = makeButton(title: "Alert with Cancel Button", color: .systemPink) { [weak self] in
        self?.viewModel.showCustomAlert(style: .withCancel)
    }

    private lazy var mandatoryCustomAlertButton = makeButton(title: "Mandatory (no background tap)", color: .brown) { [weak self] in
        self?.viewModel.showCustomAlert(style: .noDismissOnBackground)
    }

    private lazy var customContentAlertButton = makeButton(title: "Custom Content View", color: .systemTeal) { [weak self] in
        self?.viewModel.showCustomAlert(style: .customContent)
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
                        actionSnackbarButton
                        toastButton
                        activityButton
                        detentsSheetButton
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
                    description: "CustomAlertViewController accepts any UIView as content — from the standard AlertView to fully bespoke layouts. A modal effect over this screen: the view model fires a ViewEvent and the controller presents it from updateContent()."
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

    /// Acts on each `viewModel.event` once, however many times the hook re-runs.
    private var eventCursor = ViewEventCursor()

    override func updateContent() {
        super.updateContent()
        eventCursor.consume(viewModel.event) { [weak self] event in
            switch event {
            case .showCustomAlert(let style): self?.showCustomAlert(style: style)
            }
        }
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

// MARK: - Custom alerts
private extension AlertsViewController {
    func showCustomAlert(style: CustomAlertStyle) {
        switch style {
        case .basic:
            presentCustomAlert(
                AlertView(viewModel: AlertViewModelPayload(
                    icon: UIImage(systemName: "bell.fill"),
                    title: "Notification",
                    attributedMessage: NSAttributedString(string: "This uses AlertView with an icon and a single confirm button. Tap the background or press Got it to dismiss."),
                    actionButtonTitle: "Got it",
                    onActionButtonPressedHandler: { [weak self] in self?.dismiss(animated: true) }
                )),
                onBackgroundTap: { [weak self] in self?.dismiss(animated: true) }
            )

        case .withCancel:
            presentCustomAlert(
                AlertView(viewModel: AlertViewModelPayload(
                    icon: UIImage(systemName: "trash.fill"),
                    title: "Delete Item?",
                    attributedMessage: NSAttributedString(string: "This action cannot be undone. The item will be permanently removed."),
                    actionButtonTitle: "Delete",
                    cancelButtonTitle: "Cancel",
                    onActionButtonPressedHandler: { [weak self] in
                        self?.dismiss(animated: true)
                        Snackbar.show(.init(message: "Item deleted"))
                    },
                    onCancelButtonPressedHandler: { [weak self] in self?.dismiss(animated: true) }
                )),
                onBackgroundTap: { [weak self] in self?.dismiss(animated: true) }
            )

        case .noDismissOnBackground:
            presentCustomAlert(
                AlertView(viewModel: AlertViewModelPayload(
                    title: "Mandatory Action",
                    attributedMessage: NSAttributedString(string: "Tapping outside this alert does nothing. You must press the button below to dismiss."),
                    actionButtonTitle: "I Understand",
                    onActionButtonPressedHandler: { [weak self] in self?.dismiss(animated: true) },
                    shouldHandleBackgroundClick: false
                )),
                onBackgroundTap: nil
            )

        case .customContent:
            presentCustomAlert(makeSuccessCard(), onBackgroundTap: { [weak self] in self?.dismiss(animated: true) })
        }
    }

    func presentCustomAlert(_ content: UIView, onBackgroundTap handler: CompletionHandler) {
        let vc = CustomAlertWireframe.createModule(content, onDismissRequested: handler)
        present(vc, animated: true)
    }

    func makeSuccessCard() -> UIView {
        VStack(
            margins: .init(top: 32, left: 24, bottom: 28, right: 24),
            spacing: 16
        ) {
            VStack(alignment: .center) {
                UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
                    .tintColor(.systemGreen)
                    .contentMode(.scaleAspectFit)
                    .setConstraints { $0.set(width: 64); $0.set(height: 64) }
            }
            UILabel()
                .text("Payment Sent!")
                .font(.boldSystemFont(ofSize: 22))
                .textAlignment(.center)
                .textColor(.label)
            UILabel()
                .text("Your transfer of $150.00 was processed successfully.")
                .font(.systemFont(ofSize: 15))
                .textAlignment(.center)
                .textColor(.secondaryLabel)
                .numberOfLines(0)
            UIButton(configuration: .filled()
                .with {
                    $0.title = "Done"
                    $0.baseBackgroundColor = .systemGreen
                    $0.cornerStyle = .capsule
                }
            )
            .onTap { [weak self] in self?.dismiss(animated: true) }
            .setConstraints { $0.set(height: 46) }
        }
        .backgroundColor(.systemBackground)
    }
}
