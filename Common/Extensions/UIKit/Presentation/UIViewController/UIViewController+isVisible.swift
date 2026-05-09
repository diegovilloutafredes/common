//
//  UIViewController+isVisible.swift
//

import UIKit

extension UIViewController {
    
    /// Returns `true` if the view controller's view is in a window.
    public var isVisible: Bool { viewIfLoaded?.window != nil }
}
