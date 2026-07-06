//
//  PaddingLabel.swift
//

import UIKit

/// A `UILabel` that insets its text by a configurable ``UIEdgeInsets``.
///
/// `UILabel` has no built-in content insets; `PaddingLabel` adds them, which is
/// what you want for chips, tags, and badges. Combine it with rounding for a pill:
///
/// ```swift
/// PaddingLabel(padding: .init(all: 4))
///     .text("NEW")
///     .backgroundColor(.systemPink)
///     .setAsRoundedView(radius: 4)
/// ```
///
/// The padding is reflected in ``intrinsicContentSize`` and, unlike a plain
/// inset hack, in multi-line layout: wrapped text stays within the horizontal
/// insets because ``textRect(forBounds:limitedToNumberOfLines:)`` wraps against
/// the inset width.
public final class PaddingLabel: UILabel {

    /// The insets applied around the text on every edge.
    public let padding: UIEdgeInsets

    /// Creates a label that insets its text by `padding` on all four edges.
    /// - Parameter padding: The content insets. Defaults to `.zero`, in which
    ///   case the label behaves like a plain `UILabel`.
    public init(padding: UIEdgeInsets = .zero) {
        self.padding = padding
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func drawText(in rect: CGRect) {
        super.drawText(in: insetClamped(rect))
    }

    // `intrinsicContentSize` is intentionally NOT overridden: `UILabel` derives
    // it from `textRect(forBounds:limitedToNumberOfLines:)`, so the override
    // below already accounts for the padding. Adding it here too double-counts it.
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        // Wrap against the inset width, then re-expand by the padding so the
        // label reserves room for the insets around the wrapped text.
        var rect = super.textRect(forBounds: insetClamped(bounds), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= padding.left
        rect.origin.y -= padding.top
        rect.size.width += padding.left + padding.right
        rect.size.height += padding.top + padding.bottom
        return rect
    }

    /// Insets `rect` by the padding, clamping the size at zero: a rect smaller
    /// than the padding must never hand `UILabel` a negative-size rect, which
    /// collapses its measurement (zero-height text under width compression).
    private func insetClamped(_ rect: CGRect) -> CGRect {
        var inset = rect.inset(by: padding)
        inset.size.width = max(0, inset.size.width)
        inset.size.height = max(0, inset.size.height)
        return inset
    }
}
