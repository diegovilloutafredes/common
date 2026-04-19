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
        push(AlertsWireframe.createModule())
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
