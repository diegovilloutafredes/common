//
//  NavigationBarVisibilityTogglable.swift
//

import UIKit

// MARK: - NavigationBarVisibilityTogglable
public protocol NavigationBarVisibilityTogglable: AnyObject {
    func showNavigationBar(animated: Bool)
    func hideNavigationBar(animated: Bool)
}

// MARK: - where Self: UIViewController
extension NavigationBarVisibilityTogglable where Self: UIViewController {
    public func showNavigationBar(animated: Bool = true) {
        guard let nc = navigationController, nc.isNavigationBarHidden else { return }
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    public func hideNavigationBar(animated: Bool = true) {
        guard let nc = navigationController, !nc.isNavigationBarHidden else { return }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
