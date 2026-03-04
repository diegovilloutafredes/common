//
//  SceneDelegate.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - SceneDelegate
final class SceneDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIWindowSceneDelegate
extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let viewModel = MyViewModelPayload()
        let vc = ViewController(viewModel: viewModel)
        window?.set(rootViewController: vc)
    }

    func sceneDidDisconnect(_ scene: UIScene) { Logger.log(self) }
    func sceneDidBecomeActive(_ scene: UIScene) { Logger.log(self) }
    func sceneWillResignActive(_ scene: UIScene) { Logger.log(self) }
    func sceneWillEnterForeground(_ scene: UIScene) { Logger.log(self) }
    func sceneDidEnterBackground(_ scene: UIScene) { Logger.log(self) }
}
