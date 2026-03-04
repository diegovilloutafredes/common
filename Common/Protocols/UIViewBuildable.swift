//
//  UIViewBuildable.swift
//

import UIKit

// MARK: - UIViewBuildable
// MARK: - UIViewBuildable
/// A protocol for views that define their content using a `UIViewBuilder`.
public protocol UIViewBuildable {
    
    /// The main view defined by the implementation.
    @UIViewBuilder var mainView: UIView { get }
}
