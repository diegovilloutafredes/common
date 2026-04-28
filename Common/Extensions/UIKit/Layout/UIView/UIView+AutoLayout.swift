//
//  UIView+AutoLayout.swift
//

import UIKit

// MARK: - LayoutAnchorProvider

/// An internal protocol that UIView and UILayoutGuide both satisfy, enabling generic snap implementations.
protocol LayoutAnchorProvider {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
}

extension UIView: LayoutAnchorProvider {}
extension UILayoutGuide: LayoutAnchorProvider {}

// MARK: - Align Center X/Y

extension UIView {

    /// Aligns center X with another view.
    @discardableResult public func alignCenterX(with view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: inset).with { $0.isActive = true }
    }

    /// Aligns center Y with another view.
    @discardableResult public func alignCenterY(with view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: inset).with { $0.isActive = true }
    }
}

// MARK: - Pin X/Y Anchors with an Inset

extension UIView {

    @discardableResult public func pinXAnchor(origin: NSLayoutXAxisAnchor, to anchor: NSLayoutXAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return origin.constraint(equalTo: anchor, constant: inset).with { $0.isActive = true }
    }

    @discardableResult public func pinYAnchor(origin: NSLayoutYAxisAnchor, to anchor: NSLayoutYAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return origin.constraint(equalTo: anchor, constant: inset).with { $0.isActive = true }
    }
}

// MARK: - Pin X/Y Anchors with a Multiplier

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

// MARK: - Pin Top/Bottom/Lead/Trail/Center Anchors with an Inset

extension UIView {

    @discardableResult public func pinTop(to anchor: NSLayoutYAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinYAnchor(origin: topAnchor, to: anchor, inset: inset)
    }

    @discardableResult public func pinBottom(to anchor: NSLayoutYAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinYAnchor(origin: bottomAnchor, to: anchor, inset: -inset)
    }

    @discardableResult public func pinLeading(to anchor: NSLayoutXAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinXAnchor(origin: leadingAnchor, to: anchor, inset: inset)
    }

    @discardableResult public func pinTrailing(to anchor: NSLayoutXAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinXAnchor(origin: trailingAnchor, to: anchor, inset: -inset)
    }

    @discardableResult public func pinCenterX(to anchor: NSLayoutXAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinXAnchor(origin: centerXAnchor, to: anchor, inset: inset)
    }

    @discardableResult public func pinCenterY(to anchor: NSLayoutYAxisAnchor, inset: CGFloat = .zero) -> NSLayoutConstraint {
        pinYAnchor(origin: centerYAnchor, to: anchor, inset: inset)
    }
}

// MARK: - Pin Top/Bottom/Lead/Trail/Center Anchors with a Multiplier

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

    @discardableResult public func pinCenterXTo(anchor: NSLayoutXAxisAnchor, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        pinXAnchor(origin: centerXAnchor, to: anchor, multiplier: multiplier)
    }

    @discardableResult public func pinCenterYTo(anchor: NSLayoutYAxisAnchor, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        pinYAnchor(origin: centerYAnchor, to: anchor, multiplier: multiplier)
    }
}

// MARK: - Set Height/Width

extension UIView {

    /// Sets a fixed height constraint.
    @discardableResult public func set(height: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return heightAnchor.constraint(equalToConstant: height).with { $0.isActive = true }
    }

    /// Sets a fixed width constraint.
    @discardableResult public func set(width: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return widthAnchor.constraint(equalToConstant: width).with { $0.isActive = true }
    }

    @discardableResult public func setHeight(to dimension: NSLayoutDimension, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return heightAnchor.constraint(equalTo: dimension, multiplier: multiplier).with { $0.isActive = true }
    }

    @discardableResult public func setWidth(to dimension: NSLayoutDimension, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        return widthAnchor.constraint(equalTo: dimension, multiplier: multiplier).with { $0.isActive = true }
    }
}

// MARK: - Align Center

extension UIView {

    @discardableResult public func alignCenter(with view: UIView) -> Self {
        with {
            $0.alignCenterX(with: view)
            $0.alignCenterY(with: view)
        }
    }
}

// MARK: - Content Compression Resistance & Content Hugging Priorities

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

// MARK: - Set Ratio

extension UIView {

    /// Constrains width to height by the given ratio. Defaults to 1:1 (square).
    @discardableResult public func setRatio(_ ratio: CGFloat = 1) -> Self {
        with { $0.setWidth(to: $0.heightAnchor, multiplier: ratio) }
    }
}

// MARK: - Snap (single edge)

extension UIView {

    @discardableResult public func snapTop(to layoutGuide: UILayoutGuide, inset: CGFloat = .zero) -> NSLayoutConstraint { pinTop(to: layoutGuide.topAnchor, inset: inset) }
    @discardableResult public func snapBottom(to layoutGuide: UILayoutGuide, inset: CGFloat = .zero) -> NSLayoutConstraint { pinBottom(to: layoutGuide.bottomAnchor, inset: inset) }
    @discardableResult public func snapLeading(to layoutGuide: UILayoutGuide, inset: CGFloat = .zero) -> NSLayoutConstraint { pinLeading(to: layoutGuide.leadingAnchor, inset: inset) }
    @discardableResult public func snapTrailing(to layoutGuide: UILayoutGuide, inset: CGFloat = .zero) -> NSLayoutConstraint { pinTrailing(to: layoutGuide.trailingAnchor, inset: inset) }

    @discardableResult public func snapTop(to view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint { pinTop(to: view.topAnchor, inset: inset) }
    @discardableResult public func snapBottom(to view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint { pinBottom(to: view.bottomAnchor, inset: inset) }
    @discardableResult public func snapLeading(to view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint { pinLeading(to: view.leadingAnchor, inset: inset) }
    @discardableResult public func snapTrailing(to view: UIView, inset: CGFloat = .zero) -> NSLayoutConstraint { pinTrailing(to: view.trailingAnchor, inset: inset) }
}

// MARK: - Snap (multi-edge)

extension UIView {

    // MARK: Private generic implementations

    @discardableResult private func _snap(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with {
            $0.pinTop(to: a.topAnchor, inset: insets.top)
            $0.pinBottom(to: a.bottomAnchor, inset: insets.bottom)
            $0.pinLeading(to: a.leadingAnchor, inset: insets.left)
            $0.pinTrailing(to: a.trailingAnchor, inset: insets.right)
        }
    }

    @discardableResult private func _snapLeadTop(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinLeading(to: a.leadingAnchor, inset: insets.left); $0.pinTop(to: a.topAnchor, inset: insets.top) }
    }

    @discardableResult private func _snapTopTrail(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinTop(to: a.topAnchor, inset: insets.top); $0.pinTrailing(to: a.trailingAnchor, inset: insets.right) }
    }

    @discardableResult private func _snapLeadBottom(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinLeading(to: a.leadingAnchor, inset: insets.left); $0.pinBottom(to: a.bottomAnchor, inset: insets.bottom) }
    }

    @discardableResult private func _snapBottomTrail(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinBottom(to: a.bottomAnchor, inset: insets.bottom); $0.pinTrailing(to: a.trailingAnchor, inset: insets.right) }
    }

    @discardableResult private func _snapLeadTrail(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinLeading(to: a.leadingAnchor, inset: insets.left); $0.pinTrailing(to: a.trailingAnchor, inset: insets.right) }
    }

    @discardableResult private func _snapTopBottom(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinTop(to: a.topAnchor, inset: insets.top); $0.pinBottom(to: a.bottomAnchor, inset: insets.bottom) }
    }

    @discardableResult private func _snapTopLeadBottom(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinTop(to: a.topAnchor, inset: insets.top); $0.pinLeading(to: a.leadingAnchor, inset: insets.left); $0.pinBottom(to: a.bottomAnchor, inset: insets.bottom) }
    }

    @discardableResult private func _snapLeadTopTrail(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinLeading(to: a.leadingAnchor, inset: insets.left); $0.pinTop(to: a.topAnchor, inset: insets.top); $0.pinTrailing(to: a.trailingAnchor, inset: insets.right) }
    }

    @discardableResult private func _snapTopTrailBottom(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinTop(to: a.topAnchor, inset: insets.top); $0.pinTrailing(to: a.trailingAnchor, inset: insets.right); $0.pinBottom(to: a.bottomAnchor, inset: insets.bottom) }
    }

    @discardableResult private func _snapLeadBottomTrail(to a: some LayoutAnchorProvider, insets: UIEdgeInsets) -> Self {
        with { $0.pinBottom(to: a.bottomAnchor, inset: insets.bottom); $0.pinLeading(to: a.leadingAnchor, inset: insets.left); $0.pinTrailing(to: a.trailingAnchor, inset: insets.right) }
    }

    // MARK: Public — UILayoutGuide

    /// Snaps all edges to a layout guide.
    @discardableResult public func snap(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snap(to: layoutGuide, insets: insets) }
    @discardableResult public func snapLeadTop(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapLeadTop(to: layoutGuide, insets: insets) }
    @discardableResult public func snapTopTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapTopTrail(to: layoutGuide, insets: insets) }
    @discardableResult public func snapLeadBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapLeadBottom(to: layoutGuide, insets: insets) }
    @discardableResult public func snapBottomTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapBottomTrail(to: layoutGuide, insets: insets) }
    @discardableResult public func snapLeadTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapLeadTrail(to: layoutGuide, insets: insets) }
    @discardableResult public func snapTopBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapTopBottom(to: layoutGuide, insets: insets) }
    @discardableResult public func snapTopLeadBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapTopLeadBottom(to: layoutGuide, insets: insets) }
    @discardableResult public func snapLeadTopTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapLeadTopTrail(to: layoutGuide, insets: insets) }
    @discardableResult public func snapTopTrailBottom(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapTopTrailBottom(to: layoutGuide, insets: insets) }
    @discardableResult public func snapLeadBottomTrail(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> Self { _snapLeadBottomTrail(to: layoutGuide, insets: insets) }

    // MARK: Public — UIView

    /// Snaps all edges to another view.
    @discardableResult public func snap(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snap(to: view, insets: insets) }
    @discardableResult public func snapLeadTop(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapLeadTop(to: view, insets: insets) }
    @discardableResult public func snapTopTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapTopTrail(to: view, insets: insets) }
    @discardableResult public func snapLeadBottom(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapLeadBottom(to: view, insets: insets) }
    @discardableResult public func snapBottomTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapBottomTrail(to: view, insets: insets) }
    @discardableResult public func snapLeadTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapLeadTrail(to: view, insets: insets) }
    @discardableResult public func snapTopBottom(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapTopBottom(to: view, insets: insets) }
    @discardableResult public func snapTopLeadBottom(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapTopLeadBottom(to: view, insets: insets) }
    @discardableResult public func snapLeadTopTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapLeadTopTrail(to: view, insets: insets) }
    @discardableResult public func snapTopTrailBottom(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapTopTrailBottom(to: view, insets: insets) }
    @discardableResult public func snapLeadBottomTrail(to view: UIView, insets: UIEdgeInsets = .zero) -> Self { _snapLeadBottomTrail(to: view, insets: insets) }
}
