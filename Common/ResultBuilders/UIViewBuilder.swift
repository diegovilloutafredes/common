//
//  UIViewBuilder.swift
//

import UIKit

@resultBuilder
/// A result builder that constructs a `UIView` from a list of subviews.
public struct UIViewBuilder {
    
    /// Builds a block of subviews into a single parent `UIView`.
    public static func buildBlock(_ components: UIView...) -> UIView { .init { components } }
}
