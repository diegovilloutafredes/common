//
//  UITapGestureRecognizer+didTapAttributedTextInLabel.swift
//

import UIKit

// MARK: - UITapGestureRecognizer+didTapAttributedTextInLabel
extension UITapGestureRecognizer {
    public func didTapAttributedTextInLabel(label: UILabel, inRange: NSRange) -> Bool {
            guard let attributedString = label.attributedText else { return false }
            let targetRange = inRange
            // IMPORTANT label correct font for NSTextStorage needed
            let mutableAttribString = NSMutableAttributedString(attributedString: attributedString)
            mutableAttribString.addAttributes(
                [NSAttributedString.Key.font: label.font ?? UIFont.smallSystemFontSize],
                range: NSRange(location: .zero, length: attributedString.length)
            )
            // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: CGSize.zero)
            let textStorage = NSTextStorage(attributedString: mutableAttribString)

            // Configure layoutManager and textStorage
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)

            // Configure textContainer
            textContainer.lineFragmentPadding = 0.0
            textContainer.lineBreakMode = label.lineBreakMode
            textContainer.maximumNumberOfLines = label.numberOfLines
            let labelSize = label.bounds.size
            textContainer.size = labelSize

            // Find the tapped character location and compare it to the specified range
            let locationOfTouchInLabel = self.location(in: label)
            let textBoundingBox = layoutManager.usedRect(for: textContainer)
            let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
            let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y:
                locationOfTouchInLabel.y - textContainerOffset.y)
            let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

            return NSLocationInRange(indexOfCharacter, targetRange)
        }
}
