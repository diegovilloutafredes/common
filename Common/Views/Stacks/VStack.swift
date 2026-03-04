//
//  VStack.swift
//

import UIKit

// MARK: - VStack
// MARK: - VStack

/// A convenience class for creating vertical stack views.
public final class VStack: Stack {
    
    /// Initializes a new vertical stack view.
    /// - Parameters:
    ///   - alignment: The alignment of the arranged subviews generally.
    ///   - distribution: The distribution of the arranged subviews.
    ///   - margins: The layout margins of the stack view.
    ///   - spacing: The distance between the edges of the arranged subviews.
    ///   - views: A closure returning the list of views to arrange.
    public init(
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        margins: UIEdgeInsets = .zero,
        spacing: CGFloat = .zero,
        @UIViewsBuilder views: () -> [UIView] = {[]}
    ) {
        super.init()
        vertical(alignment: alignment, distribution: distribution, margins: margins, spacing: spacing)
        self.views(views)
    }
}
