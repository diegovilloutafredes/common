//
//  LargeTitleSettable.swift
//

import UIKit

// MARK: - LargeTitleSettable
public protocol LargeTitleSettable: AnyObject {
    func disableLargeTitle()
    func enableLargeTitle()
}

extension LargeTitleSettable where Self: UINavigationController {
    public func disableLargeTitle() { navigationBar.prefersLargeTitles(false) }
    public func enableLargeTitle() { navigationBar.prefersLargeTitles(true) }
}

// MARK: - Default Implementation
extension LargeTitleSettable where Self: UIViewController {
    public func disableLargeTitle() { navigationController?.disableLargeTitle() }
    public func enableLargeTitle() { navigationController?.enableLargeTitle() }
}
