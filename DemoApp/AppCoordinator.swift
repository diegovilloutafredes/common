//
//  AppCoordinator.swift
//  DemoApp
//

import UIKit
import Common

// MARK: - AppCoordinator
/// Navigation only: answers Home's requests by pushing a module or starting a child flow.
final class AppCoordinator: BaseCoordinator {
    override func start() {
        set(HomeWireframe.createModule { [weak self] request in
            guard let self else { return }
            switch request {
            case .declarativeUI: push(DeclarativeUIWireframe.createModule())
            case .networking: push(NetworkingWireframe.createModule())
            case .storage: push(StorageWireframe.createModule())
            case .alerts: push(AlertsWireframe.createModule())
            case .localAuth: push(LocalAuthWireframe.createModule())
            case .extensions: push(ExtensionsWireframe.createModule())
            case .onboarding: addChildAndStart(OnboardingCoordinator(navigationController: navigationController))
            case .forms: push(FormsWireframe.createModule())
            case .lists: push(ListsWireframe.createModule())
            case .utilities: push(UtilitiesWireframe.createModule())
            case .camera: push(CameraWireframe.createModule())
            case .coordinatorDemo: addChildAndStart(CoordinatorDemoCoordinator(navigationController: navigationController))
            case .imageLoading: push(ImageLoadingWireframe.createModule())
            case .typography: push(TypographyWireframe.createModule())
            case .components: push(componentsViewController)
            case .observation: push(ObservationWireframe.createModule())
            }
        })
    }

    private var componentsViewController: UIViewController {
        ComponentsWireframe.createModule { [weak self] request in
            switch request {
            case .goBack: self?.pop()
            }
        }
    }
}
