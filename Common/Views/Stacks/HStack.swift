//
//  HStack.swift
//

import UIKit

// MARK: - HStack
// MARK: - HStack

/// A convenience class for creating horizontal stack views.
public final class HStack: Stack {
    
    /// Initializes a new horizontal stack view.
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
        horizontal(alignment: alignment, distribution: distribution, margins: margins, spacing: spacing)
        self.views(views)
    }
}
