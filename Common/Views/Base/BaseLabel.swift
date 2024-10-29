//
//  BaseLabel.swift
//

import UIKit

// MARK: - BaseLabel
open class BaseLabel: UILabel {
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
