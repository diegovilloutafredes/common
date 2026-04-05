//
//  AppCoordinator.swift
//  DemoApp
//

import UIKit
import Common

// MARK: - AppCoordinator
final class AppCoordinator: BaseCoordinator {
    override func start() {
        let vc = HomeWireframe.createModule(coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }

    func showDeclarativeUI() {
        let vc = DeclarativeUIWireframe.createModule()
        navigationController.pushViewController(vc, animated: true)
    }

    func showNetworking() {
        let vc = NetworkingWireframe.createModule()
        navigationController.pushViewController(vc, animated: true)
    }

    func showStorage() {
        let vc = StorageWireframe.createModule()
        navigationController.pushViewController(vc, animated: true)
    }

    func showAlerts() {
        let vc = AlertsWireframe.createModule()
        navigationController.pushViewController(vc, animated: true)
    }

    func showLocalAuth() {
        let vc = LocalAuthWireframe.createModule()
        navigationController.pushViewController(vc, animated: true)
    }

    func showExtensions() {
        let vc = ExtensionsWireframe.createModule()
        navigationController.pushViewController(vc, animated: true)
    }
}
