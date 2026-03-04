//
//  BaseButton.swift
//

import UIKit

// MARK: - BaseButton
// MARK: - BaseButton

/// A base button class that provides a standardized setup point.
open class BaseButton: UIButton {
    
    /// Initializes a new button.
    public init() {
        super.init(frame: .zero)
        setupView()
    }

    /// Initializes a new button with the specified frame.
    /// - Parameter frame: The frame rectangle for the button.
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
    /// Override this method to customize the button's appearance and behavior during initialization.
    open func setupView() {}
}
