//
//  UIViewBuilder.swift
//

import UIKit

@resultBuilder
/// A result builder that constructs a single `UIView` for use as a root view.
///
/// Designed for `mainView` properties. Returns the view directly — no transparent wrapper.
/// Supports `if/else`, `if let`, and `if #available` at the root level.
///
/// - Note: A single statement is required — multiple top-level views are a compile error.
///   Wrap siblings in a `VStack` or `HStack`.
/// - Warning: `if condition { view }` with no `else` returns an invisible `UIView()` when
///   `condition` is false. Always provide an `else` branch at the root level.
public struct UIViewBuilder {

    /// Returns the single component directly — eliminates the transparent `UIView` wrapper.
    public static func buildBlock(_ component: UIView) -> UIView { component }

    /// Supports `if condition { ViewA() } else { ViewB() }` at the root level.
    public static func buildEither(first component: UIView) -> UIView { component }

    /// Supports `if condition { ViewA() } else { ViewB() }` at the root level.
    public static func buildEither(second component: UIView) -> UIView { component }

    /// Supports `if let x = optional { SomeView(x) }` at the root level.
    /// - Warning: Returns an invisible `UIView()` when the optional is nil and there is no `else`.
    public static func buildOptional(_ component: UIView?) -> UIView {
        if let component { return component }
        #if DEBUG
        assertionFailure("UIViewBuilder: 'if' without 'else' — add an else branch to avoid an invisible placeholder.")
        #endif
        let placeholder = UIView()
        placeholder.isHidden = true
        placeholder.isUserInteractionEnabled = false
        return placeholder
    }

    /// Supports `if #available(iOS X, *) { ... }` at the root level.
    public static func buildLimitedAvailability(_ component: UIView) -> UIView { component }
}
