//
//  PillUILabel.swift
//

import UIKit

final class PillUILabel: BaseLabel {
    private var verticalPad: CGFloat = 8
    private var horizontalPad: CGFloat = 4

    override var intrinsicContentSize: CGSize {
        let contentSize = super.intrinsicContentSize
        let newWidth = contentSize.width + (2 * horizontalPad)
        let newHeight = contentSize.height + (2 * verticalPad)
        return .init(width: newWidth, height: newHeight)
    }

    override func setupView() {
        adjustsFontSizeToFitWidth(true)
        backgroundColor(.black)
        font(.systemFont(ofSize: 16))
        numberOfLines()
        textAlignment(.center)
        textColor(.white)
        setAsRoundedView()
    }
}
