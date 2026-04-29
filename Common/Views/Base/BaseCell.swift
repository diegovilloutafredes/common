//
//  BaseCell.swift
//

import UIKit

// MARK: - BaseCell

/// A base collection view cell that conforms to `UIViewBuildable`.
/// It provides a consistent setup for hosting a main view within the cell.
open class BaseCell: UICollectionViewCell, UIViewBuildable {
    
    /// The main view of the cell.
    /// Subclasses should override this to provide their custom view hierarchy.
    /// By default, returns an empty `UIView`.
    @UIViewBuilder open var mainView: UIView { UIView() }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.subviews { mainView.setConstraints { $0.snap(to: $1) } }
        setupCell()
    }

    @available(*, unavailable)
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }

    /// Sets up the cell after `mainView` is installed.
    /// Override to perform additional configuration (gesture recognizers, data binding, etc.).
    ///
    /// **Retain cycles:** closures stored inside subviews (e.g. `.onTap {}`) must capture `self`
    /// weakly — the subview is owned by the cell's view hierarchy, creating a reference cycle
    /// if `self` is captured strongly.
    open func setupCell() {}
}
