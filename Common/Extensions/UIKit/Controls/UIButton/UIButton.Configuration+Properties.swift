//
//  UIButton.Configuration+Properties.swift
//

import UIKit

extension UIButton.Configuration {
    
    /// Sets the attributed title and returns self.
    @discardableResult
    public func attributedTitle(_ attributedTitle: AttributedString) -> Self {
        with { $0.attributedTitle = attributedTitle }
    }

    /// Sets the base background color and returns self.
    @discardableResult
    public func baseBackgroundColor(_ baseBackgroundColor: UIColor) -> Self {
        with { $0.baseBackgroundColor = baseBackgroundColor }
    }

    /// Sets the base foreground color and returns self.
    @discardableResult
    public func baseForegroundColor(_ baseForegroundColor: UIColor) -> Self {
        with { $0.baseForegroundColor = baseForegroundColor }
    }

    /// Sets the corner style and returns self.
    @discardableResult
    public func cornerStyle(_ cornerStyle: CornerStyle) -> Self {
        with { $0.cornerStyle = cornerStyle }
    }

    /// Sets the image and returns self.
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        with { $0.image = image }
    }

    /// Sets the image padding and returns self.
    @discardableResult
    public func imagePadding(_ imagePadding: CGFloat) -> Self {
        with { $0.imagePadding = imagePadding }
    }

    /// Sets the image placement and returns self.
    @discardableResult
    public func imagePlacement(_ imagePlacement: NSDirectionalRectEdge) -> Self {
        with { $0.imagePlacement = imagePlacement }
    }
}
