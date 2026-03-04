//
//  PillUILabel.swift
//

import UIKit

/// A label with pill-shaped background and padding.
final class PillUILabel: BaseLabel {
    private var verticalPad: CGFloat = 8
    private var horizontalPad: CGFloat = 8

    override var intrinsicContentSize: CGSize {
        let contentSize = super.intrinsicContentSize
        let newWidth = contentSize.width + (2 * horizontalPad)
        let newHeight = contentSize.height + (2 * verticalPad)
        return .init(width: newWidth, height: newHeight)
    }

    override func setupView() {
        adjustsFontSizeToFitWidth()
        backgroundColor(.black)
        font(.systemFont(ofSize: 16))
        numberOfLines()
        textAlignment(.center)
        textColor(.white)
        onLayoutSubviews { $0.setAsRoundedView() }
    }
}
