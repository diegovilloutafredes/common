//
//  Stack.swift
//

import UIKit

// MARK: Stack
public class Stack: UIStackView {
    public init() {
        super.init(frame: .zero)
        insetsLayoutMarginsFromSafeArea(false)
        isLayoutMarginsRelativeArrangement(true)
    }

    @available(*, unavailable)
    required public init(coder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }
}
