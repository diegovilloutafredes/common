//
//  BaseCell.swift
//

import UIKit

// MARK: - BaseCell
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
        subviews { mainView.setConstraints { $0.snap(to: $1) } }
        setupCell()
    }

    @available(*, unavailable)
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }

    /// Sets up the cell.
    /// Override this method to perform additional configuration during initialization.
    open func setupCell() {}
}
