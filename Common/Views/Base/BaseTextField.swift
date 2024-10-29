//
//  BaseTextField.swift
//

import UIKit

// MARK: - BaseTextField
open class BaseTextField: UITextField {
    public init() {
        super.init(frame: .zero)
        setupView()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }

    open func setupView() {}
}

// MARK: - BaseDNITextField
open class BaseDNITextField: BaseTextField {
    open override func setupView() {
        allowedChars("0123456789kK")
        .maxLength(9)
        .onEditingDidBegin { $0.text($0.text?.removeRUTFormat()) }
        .onEditingDidEnd { $0.text($0.text?.formatAsRUT()) }
    }
}
