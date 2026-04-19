//
//  BaseView.swift
//

import UIKit

// MARK: - BaseView
// MARK: - BaseView

/// A base view class that conforms to `UIViewBuildable`.
/// It provides a consistent setup for hosting a main view within the view.
open class BaseView: UIView, UIViewBuildable {
    
    /// The main view of the component.
    /// Subclasses should override this to provide their custom view hierarchy.
    /// By default, returns an empty `UIView`.
    @UIViewBuilder open var mainView: UIView { UIView() }

    /// Initializes a new view.
    public init() {
        super.init(frame: .zero)
        let content = mainView
        addSubview(content)
        if content.translatesAutoresizingMaskIntoConstraints { content.snap(to: self) }
        setupView()
    }

    /// Initializes a new view with the specified frame.
    /// - Parameter frame: The frame rectangle for the view.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        let content = mainView
        addSubview(content)
        if content.translatesAutoresizingMaskIntoConstraints { content.snap(to: self) }
        setupView()
    }

    @available(*, unavailable)
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }

    /// Sejts up the view.
    /// Default implementation sets the background color to clear.
    open func setupView() { backgroundColor(.clear) }
}
