//
//  BaseLabel.swift
//

import UIKit

// MARK: - BaseLabel
// MARK: - BaseLabel

/// A base label class that provides a standardized setup point.
open class BaseLabel: UILabel {
    
    /// Initializes a new label.
    public init() {
        super.init(frame: .zero)
        setupView()
    }

    /// Initializes a new label with the specified frame.
    /// - Parameter frame: The frame rectangle for the label.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }

    /// Sets up the view.
    /// Override this method to customize the label's appearance during initialization.
    open func setupView() {}
}
