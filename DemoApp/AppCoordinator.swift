//
//  AppCoordinator.swift
//  DemoApp
//

import UIKit
import Common

// MARK: - AppCoordinator
final class AppCoordinator: BaseCoordinator {
    override func start() {
        set(HomeWireframe.createModule(coordinator: self))
        if ProcessInfo.processInfo.arguments.contains("-SmokeTestSnackbar") {
            dispatchOnMainAfter(.now() + 1) {
                Snackbar.show(.init(message: "Testing snackbar margins", duration: .long))
            }
        }
    }

    func showDeclarativeUI() {
        push(DeclarativeUIWireframe.createModule())
    }

    func showNetworking() {
        push(NetworkingWireframe.createModule())
    }

    func showStorage() {
        push(StorageWireframe.createModule())
    }

    func showAlerts() {
        push(AlertsWireframe.createModule(coordinator: self))
    }

    func showLocalAuth() {
        push(LocalAuthWireframe.createModule())
    }

    func showExtensions() {
        push(ExtensionsWireframe.createModule())
    }

    func showOnboarding() {
        let vc = OnboardingWireframe.createModule { [weak self] action in
            switch action {
            case .skip, .begin:
                self?.pop()
            }
        }
        push(vc)
    }

    func showForms() {
        push(FormsWireframe.createModule())
    }
}

// MARK: - Custom Alert Presentation
extension AppCoordinator {
    func showCustomAlert(style: CustomAlertStyle) {
        switch style {
        case .basic:
            presentCustomAlert(
                AlertView(viewModel: AlertViewModelPayload(
                    icon: UIImage(systemName: "bell.fill"),
                    title: "Notification",
                    attributedMessage: NSAttributedString(string: "This uses AlertView with an icon and a single confirm button. Tap the background or press Got it to dismiss."),
                    actionButtonTitle: "Got it",
                    onActionButtonPressedHandler: { [weak self] in self?.dismiss() }
                )),
                onBackgroundTap: { [weak self] in self?.dismiss() }
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
                        self?.dismiss()
                        Snackbar.show(.init(message: "Item deleted"))
                    },
                    onCancelButtonPressedHandler: { [weak self] in self?.dismiss() }
                )),
                onBackgroundTap: { [weak self] in self?.dismiss() }
            )

        case .noDismissOnBackground:
            presentCustomAlert(
                AlertView(viewModel: AlertViewModelPayload(
                    title: "Mandatory Action",
                    attributedMessage: NSAttributedString(string: "Tapping outside this alert does nothing. You must press the button below to dismiss."),
                    actionButtonTitle: "I Understand",
                    onActionButtonPressedHandler: { [weak self] in self?.dismiss() },
                    shouldHandleBackgroundClick: false
                )),
                onBackgroundTap: nil
            )

        case .customContent:
            presentCustomAlert(makeSuccessCard(), onBackgroundTap: { [weak self] in self?.dismiss() })
        }
    }

    private func presentCustomAlert(_ content: UIView, onBackgroundTap handler: CompletionHandler) {
        let vc = CustomAlertWireframe.createModule(content, onDismissRequested: handler)
        present(.overCurrent, viewController: vc)
    }

    private func makeSuccessCard() -> UIView {
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
            .onTap { [weak self] in self?.dismiss() }
            .setConstraints { $0.set(height: 46) }
        }
        .backgroundColor(.systemBackground)
    }
}
