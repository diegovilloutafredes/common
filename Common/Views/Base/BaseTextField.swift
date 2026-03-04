//
//  BaseTextField.swift
//

import UIKit

// MARK: - BaseTextField
// MARK: - BaseTextField

/// A base text field class that provides a standardized setup point.
open class BaseTextField: UITextField {
    
    /// Initializes a new text field.
    public init() {
        super.init(frame: .zero)
        setupView()
    }

    /// Initializes a new text field with the specified frame.
    /// - Parameter frame: The frame rectangle for the text field.
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
    /// Override this method to customize the text field's appearance and behavior during initialization.
    open func setupView() {}
}
