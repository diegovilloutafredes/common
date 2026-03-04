//
//  BaseReusableView.swift
//

import UIKit

// MARK: - BaseReusableView
// MARK: - BaseReusableView

/// A base collection reusable view (e.g., for headers or footers) that conforms to `UIViewBuildable`.
/// It provides a consistent setup for hosting a main view.
open class BaseReusableView: UICollectionReusableView, UIViewBuildable {
    
    /// The main view of the reusable view.
    /// Subclasses should override this to provide their custom view hierarchy.
    /// By default, returns an empty `UIView`.
    @UIViewBuilder
    open var mainView: UIView { UIView() }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        subviews { mainView.setConstraints { $0.snap(to: $1) } }
        setupView()
    }

    @available(*, unavailable)
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }

    /// Sets up the view.
    /// Override this method to perform additional configuration during initialization.
    open func setupView() {}
}
