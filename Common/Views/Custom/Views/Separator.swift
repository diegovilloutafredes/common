//
//  Separator.swift
//

import UIKit

public final class Separator: BaseView {
    private let color: UIColor
    private let height: Double

    public init(color: UIColor = .black, height: Double = 1) {
        self.color = color
        self.height = height
        super.init()
    }

    @UIViewBuilder public override var mainView: UIView {
        UIView()
            .backgroundColor(color)
            .setConstraints {
                $0.set(height: self.height)
                $0.snap(to: $1)
            }
    }

    public override func setupView() {
        backgroundColor(color)
    }
}

extension UIView {
    @discardableResult public func addSeparator(color: UIColor = .black, height: Double = 1) -> UIView {
        addSeparator(.init(color: color, height: height))
    }

    @discardableResult public func addSeparator(_ separator: Separator = .init(color: .black, height: 1)) -> UIView {
        VStack {
            self
            separator
        }
    }
}
