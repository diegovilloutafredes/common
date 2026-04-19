//
//  UIViewBuilder.swift
//

import UIKit

@resultBuilder
/// A result builder that constructs a single `UIView` for use as a root view.
///
/// Designed for `mainView` properties. Returns the view directly — no transparent wrapper.
/// Supports `if/else` and `if let` at the root level.
public struct UIViewBuilder {

    /// Returns the single component directly — eliminates the transparent `UIView` wrapper.
    public static func buildBlock(_ component: UIView) -> UIView { component }

    /// Supports `if condition { ViewA() } else { ViewB() }` at the root level.
    public static func buildEither(first component: UIView) -> UIView { component }

    /// Supports `if condition { ViewA() } else { ViewB() }` at the root level.
    public static func buildEither(second component: UIView) -> UIView { component }

    /// Supports `if let x = optional { SomeView(x) }` at the root level.
    public static func buildOptional(_ component: UIView?) -> UIView { component ?? UIView() }
}
