//
//  UIView+Init.swift
//

import UIKit

extension UIView {
    
    /// Initializes a view with subviews from a result builder.
    /// - Parameter subviews: A result builder closure providing the subviews.
    public convenience init(@UIViewsBuilder _ subviews: () -> [UIView] = {[]}) {
        self.init(frame: .zero)
        self.subviews(subviews())
    }
}
