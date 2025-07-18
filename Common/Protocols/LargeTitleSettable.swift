//
//  LargeTitleSettable.swift
//

import UIKit

// MARK: - LargeTitleSettable
public protocol LargeTitleSettable: AnyObject {
    func disableLargeTitles()
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
