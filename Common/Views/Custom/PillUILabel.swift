//
//  PillUILabel.swift
//

import UIKit

// MARK: - PillUILabel
/// A label with pill-shaped background and padding.
///
/// The padding is honored by measurement AND drawing (the same mechanism as
/// ``PaddingLabel`` — kept in sync with it), so it survives Auto Layout width
/// compression and multi-line wrap instead of living only in the intrinsic size.
public final class PillUILabel: BaseLabel {
    private var verticalPad: CGFloat = 8
    private var horizontalPad: CGFloat = 8

    private var padding: UIEdgeInsets { .init(horizontal: horizontalPad, vertical: verticalPad) }

    public override func setupView() {
        backgroundColor(.black)
        font(.systemFont(ofSize: 16))
        numberOfLines()
        textAlignment(.center)
        textColor(.white)
        setAsRoundedView()
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
