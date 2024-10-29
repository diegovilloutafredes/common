//
//  UIView+Init.swift
//

import UIKit

extension UIView {
    public convenience init(@UIViewsBuilder _ subviews: () -> [UIView] = {[]}) {
        self.init(frame: .zero)
        self.subviews(subviews())
    }
}
