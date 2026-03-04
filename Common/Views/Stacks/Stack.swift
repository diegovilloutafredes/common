//
//  Stack.swift
//

import UIKit

// MARK: Stack
// MARK: Stack

/// A subclass of `UIStackView` that enables layout margins relative arrangement by default.
public class Stack: UIStackView {
    public init() {
        super.init(frame: .zero)
        insetsLayoutMarginsFromSafeArea(false)
        isLayoutMarginsRelativeArrangement(true)
    }

    /// Initializes a new stack view with configuration parameters.
    /// - Parameters:
    ///   - alignment: The alignment of arranged subviews.
    ///   - distribution: The distribution of arranged subviews.
    ///   - margins: The layout margins.
    ///   - spacing: The spacing between arranged subviews.
    ///   - views: A closure returning the arranged subviews.
    public convenience init(
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        margins: UIEdgeInsets = .zero,
        spacing: CGFloat = .zero,
        @UIViewsBuilder views: () -> [UIView] = {[]}
    ) {
        self.init()
        self.alignment(alignment)
        self.distribution(distribution)
        self.layoutMargins(margins)
        self.spacing(spacing)
        self.views(views)
    }

    @available(*, unavailable)
    required public init(coder: NSCoder) { fatalError("NSCoder is not supported") }

    public override class var requiresConstraintBasedLayout: Bool { true }
}
