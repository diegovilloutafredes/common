//
//  UIView+AutoLayout.swift
//

import UIKit

// MARK: - AutoLayout Helpers
extension UIView {
    @discardableResult public func alignCenter(with view: UIView) -> Self {
        with {
            $0.alignCenterX(with: view)
            $0.alignCenterY(with: view)
        }
    }

    @discardableResult public func alignCenterX(with view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: inset).with { $0.isActive = true }
    }

    @discardableResult public func alignCenterY(with view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: inset).with { $0.isActive = true }
    }
}

extension UIView {
    @discardableResult public func contentCompressionResistance(priority: UILayoutPriority, axis: NSLayoutConstraint.Axis) -> Self {
        with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentCompressionResistancePriority(priority, for: axis)
        }
    }

    @discardableResult public func contentHugging(priority: UILayoutPriority, axis: NSLayoutConstraint.Axis) -> Self {
        with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentHuggingPriority(priority, for: axis)
        }
    }
}

extension UIView {
    @discardableResult public func pinXAnchor(origin: NSLayoutXAxisAnchor, to anchor: NSLayoutXAxisAnchor, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return origin.constraint(equalToSystemSpacingAfter: anchor, multiplier: multiplier).with { $0.isActive = true }
    }

    @discardableResult public func pinYAnchor(origin: NSLayoutYAxisAnchor, to anchor: NSLayoutYAxisAnchor, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return origin.constraint(equalToSystemSpacingBelow: anchor, multiplier: multiplier).with { $0.isActive = true }
    }
}

extension UIView {
    @discardableResult public func pinTopTo(anchor: NSLayoutYAxisAnchor, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        pinYAnchor(origin: topAnchor, to: anchor, multiplier: multiplier)
    }

    @discardableResult public func pinBottomTo(anchor: NSLayoutYAxisAnchor, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        pinYAnchor(origin: bottomAnchor, to: anchor, multiplier: multiplier)
    }

    @discardableResult public func pinLeadingTo(anchor: NSLayoutXAxisAnchor, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        pinXAnchor(origin: leadingAnchor, to: anchor, multiplier: multiplier)
    }

    @discardableResult public func pinTrailingTo(anchor: NSLayoutXAxisAnchor, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        pinXAnchor(origin: trailingAnchor, to: anchor, multiplier: multiplier)
    }
}

extension UIView {
    @discardableResult public func pinTop(to anchor: NSLayoutYAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return topAnchor.constraint(equalTo: anchor, constant: inset).with { $0.isActive = true }
    }

    @discardableResult public func pinBottom(to anchor: NSLayoutYAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return bottomAnchor.constraint(equalTo: anchor, constant: -inset).with { $0.isActive = true }
    }

    @discardableResult public func pinLeading(to anchor: NSLayoutXAxisAnchor, inset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return leadingAnchor.constraint(equalTo: anchor, constant: inset).with { $0.isActive = true }
    }

    @discardableResult public func pinTrailing(to anchor: NSLayoutXAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return trailingAnchor.constraint(equalTo: anchor, constant: -inset).with { $0.isActive = true }
    }
}

extension UIView {
    /// Ratio defined as a Width to Height proportion.
    /// It defaults to 1, width and height are the same.
    @discardableResult public func setRatio(_ ratio: CGFloat = 1) -> Self {
        with { $0.setWidth(to: $0.heightAnchor, multiplier: ratio) }
    }
}

extension UIView {
    @discardableResult public func set(height: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return heightAnchor.constraint(equalToConstant: height).with { $0.isActive = true }
    }

    @discardableResult public func set(width: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return widthAnchor.constraint(equalToConstant: width).with { $0.isActive = true }
    }
}

extension UIView {
    @discardableResult public func setHeight(to dimension: NSLayoutDimension, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return heightAnchor.constraint(equalTo: dimension, multiplier: multiplier).with { $0.isActive = true }
    }

    @discardableResult public func setWidth(to dimension: NSLayoutDimension, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return widthAnchor.constraint(equalTo: dimension, multiplier: multiplier).with { $0.isActive = true }
    }
}

extension UIView {
    @discardableResult public func snap(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: layoutGuide.topAnchor, inset: insets.top)
            $0.pinBottom(to: layoutGuide.bottomAnchor, inset: insets.bottom)
            $0.pinLeading(to: layoutGuide.leadingAnchor, inset: insets.left)
            $0.pinTrailing(to: layoutGuide.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapLeadTop(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinLeading(to: layoutGuide.leadingAnchor, inset: insets.left)
            $0.pinTop(to: layoutGuide.topAnchor, inset: insets.top)
        }
    }

    @discardableResult public func snapTopTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: layoutGuide.topAnchor, inset: insets.top)
            $0.pinTrailing(to: layoutGuide.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapLeadBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinLeading(to: layoutGuide.leadingAnchor, inset: insets.left)
            $0.pinBottom(to: layoutGuide.bottomAnchor, inset: insets.bottom)
        }
    }

    @discardableResult public func snapBottomTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinBottom(to: layoutGuide.bottomAnchor, inset: insets.bottom)
            $0.pinTrailing(to: layoutGuide.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapLeadTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinLeading(to: layoutGuide.leadingAnchor, inset: insets.left)
            $0.pinTrailing(to: layoutGuide.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapTopBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: layoutGuide.topAnchor, inset: insets.top)
            $0.pinBottom(to: layoutGuide.bottomAnchor, inset: insets.bottom)
        }
    }
}

extension UIView {
    @discardableResult public func snap(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: view.topAnchor, inset: insets.top)
            $0.pinBottom(to: view.bottomAnchor, inset: insets.bottom)
            $0.pinLeading(to: view.leadingAnchor, inset: insets.left)
            $0.pinTrailing(to: view.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapLeadTop(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinLeading(to: view.leadingAnchor, inset: insets.left)
            $0.pinTop(to: view.topAnchor, inset: insets.top)
        }
    }

    @discardableResult public func snapTopTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: view.topAnchor, inset: insets.top)
            $0.pinTrailing(to: view.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapLeadBottom(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinLeading(to: view.leadingAnchor, inset: insets.left)
            $0.pinBottom(to: view.bottomAnchor, inset: insets.bottom)
        }
    }

    @discardableResult public func snapBottomTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinBottom(to: view.bottomAnchor, inset: insets.bottom)
            $0.pinTrailing(to: view.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapLeadTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinLeading(to: view.leadingAnchor, inset: insets.left)
            $0.pinTrailing(to: view.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapTopBottom(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: view.topAnchor, inset: insets.top)
            $0.pinBottom(to: view.bottomAnchor, inset: insets.bottom)
        }
    }
}

extension UIView {
    @discardableResult public func snapTop(to layoutGuide: UILayoutGuide, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinTop(to: layoutGuide.topAnchor, inset: inset)
    }

    @discardableResult public func snapBottom(to layoutGuide: UILayoutGuide, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinBottom(to: layoutGuide.bottomAnchor, inset: inset)
    }

    @discardableResult public func snapLeading(to layoutGuide: UILayoutGuide, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinLeading(to: layoutGuide.leadingAnchor, inset: inset)
    }

    @discardableResult public func snapTrailing(to layoutGuide: UILayoutGuide, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinTrailing(to: layoutGuide.trailingAnchor, inset: inset)
    }
}

extension UIView {
    @discardableResult public func snapTop(to view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinTop(to: view.topAnchor, inset: inset)
    }

    @discardableResult public func snapBottom(to view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinBottom(to: view.bottomAnchor, inset: inset)
    }

    @discardableResult public func snapLeading(to view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinLeading(to: view.leadingAnchor, inset: inset)
    }

    @discardableResult public func snapTrailing(to view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinTrailing(to: view.trailingAnchor, inset: inset)
    }
}

extension UIView {
    @discardableResult public func snapTopLeadBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: layoutGuide.topAnchor, inset: insets.top)
            $0.pinLeading(to: layoutGuide.leadingAnchor, inset: insets.left)
            $0.pinBottom(to: layoutGuide.bottomAnchor, inset: insets.bottom)
        }
    }

    @discardableResult public func snapLeadTopTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinLeading(to: layoutGuide.leadingAnchor, inset: insets.left)
            $0.pinTop(to: layoutGuide.topAnchor, inset: insets.top)
            $0.pinTrailing(to: layoutGuide.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapTopTrailBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: layoutGuide.topAnchor, inset: insets.top)
            $0.pinTrailing(to: layoutGuide.trailingAnchor, inset: insets.right)
            $0.pinBottom(to: layoutGuide.bottomAnchor, inset: insets.bottom)
        }
    }

    @discardableResult public func snapLeadBottomTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinBottom(to: layoutGuide.bottomAnchor, inset: insets.bottom)
            $0.pinLeading(to: layoutGuide.leadingAnchor, inset: insets.left)
            $0.pinTrailing(to: layoutGuide.trailingAnchor, inset: insets.right)
        }
    }
}

extension UIView {
    @discardableResult public func snapTopLeadBottom(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: view.topAnchor, inset: insets.top)
            $0.pinLeading(to: view.leadingAnchor, inset: insets.left)
            $0.pinBottom(to: view.bottomAnchor, inset: insets.bottom)
        }
    }

    @discardableResult public func snapLeadTopTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinLeading(to: view.leadingAnchor, inset: insets.left)
            $0.pinTop(to: view.topAnchor, inset: insets.top)
            $0.pinTrailing(to: view.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult public func snapTopTrailBottom(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinTop(to: view.topAnchor, inset: insets.top)
            $0.pinTrailing(to: view.trailingAnchor, inset: insets.right)
            $0.pinBottom(to: view.bottomAnchor, inset: insets.bottom)
        }
    }

    @discardableResult public func snapLeadBottomTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        with {
            $0.pinBottom(to: view.bottomAnchor, inset: insets.bottom)
            $0.pinLeading(to: view.leadingAnchor, inset: insets.left)
            $0.pinTrailing(to: view.trailingAnchor, inset: insets.right)
        }
    }
}
