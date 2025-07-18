//
//  Stack.swift
//

import UIKit

// MARK: Stack
public class Stack: UIStackView {
    public init() {
        super.init(frame: .zero)
        insetsLayoutMarginsFromSafeArea(false)
        isLayoutMarginsRelativeArrangement(true)
    }

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
