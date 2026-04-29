//
//  UIViewBuildable.swift
//

import UIKit

// MARK: - UIViewBuildable
/// A protocol for views that define their content using a `UIViewBuilder`.
public protocol UIViewBuildable {
    
    /// The main view defined by the implementation.
    ///
    /// **Contract:** the framework calls this property **exactly once** and retains the returned view.
    /// Do not call it yourself — calling it a second time creates a duplicate, detached view tree.
    ///
    /// **Closures:** any closure stored by a subview inside `mainView` (e.g. via `.onTap {}`) must
    /// capture `self` weakly (`[weak self]`) to avoid a retain cycle through the cell/view hierarchy.
    @UIViewBuilder var mainView: UIView { get }
}
