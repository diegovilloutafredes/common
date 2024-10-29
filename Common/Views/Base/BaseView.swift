//
//  BaseView.swift
//

import UIKit

// MARK: - BaseView
open class BaseView: UIView, UIViewBuildable {
    @UIViewBuilder open var mainView: UIView { UIView() }

    public init() {
        super.init(frame: .zero)
        subviews { mainView.setConstraints { $0.snap(to: $1) } }
        setupView()
    }

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

    open func setupView() { backgroundColor(.clear) }
}
