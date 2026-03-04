//
//  NavigationBarVisibilityTogglable.swift
//

import UIKit

// MARK: - NavigationBarVisibilityTogglable
// MARK: - NavigationBarVisibilityTogglable
/// A protocol for objects that can toggle the visibility of the navigation bar.
public protocol NavigationBarVisibilityTogglable: AnyObject {
    
    /// Shows the navigation bar.
    /// - Parameter animated: Whether to animate the showing of the navigation bar.
    func showNavigationBar(animated: Bool)
    
    /// Hides the navigation bar.
    /// - Parameter animated: Whether to animate the hiding of the navigation bar.
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
