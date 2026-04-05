//
//  LargeTitleSettable.swift
//

import UIKit

// MARK: - LargeTitleSettable
// MARK: - LargeTitleSettable
/// A protocol for objects that can enable or disable large titles in a navigation bar.
public protocol LargeTitleSettable: AnyObject {
    
    /// Disables large titles.
    func disableLargeTitles()
    
    /// Enables large titles.
    func enableLargeTitles()
}

extension LargeTitleSettable where Self: UINavigationController {
    public func disableLargeTitles() { navigationBar.prefersLargeTitles(false) }
    public func enableLargeTitles() { navigationBar.prefersLargeTitles(true) }
}

// MARK: - Default Implementation
extension LargeTitleSettable where Self: UIViewController {
    public func disableLargeTitles() { navigationController?.disableLargeTitles() }
    public func enableLargeTitles() { navigationController?.enableLargeTitles() }
}
