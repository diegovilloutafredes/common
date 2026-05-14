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
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1))
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
        addChildAndStart(AlertsCoordinator(navigationController: navigationController))
    }

    func showLocalAuth() {
        push(LocalAuthWireframe.createModule())
    }

    func showExtensions() {
        push(ExtensionsWireframe.createModule())
    }

    func showOnboarding() {
        addChildAndStart(OnboardingCoordinator(navigationController: navigationController))
    }

    func showForms() {
        push(FormsWireframe.createModule())
    }

    func showLists() {
        push(ListsWireframe.createModule())
    }

    func showUtilities() {
        push(UtilitiesWireframe.createModule())
    }

    func showCoordinatorDemo() {
        addChildAndStart(CoordinatorDemoCoordinator(navigationController: navigationController))
    }

    func showImageLoading() {
        push(ImageLoadingWireframe.createModule())
    }

    func showTypography() {
        push(TypographyWireframe.createModule())
    }
}
