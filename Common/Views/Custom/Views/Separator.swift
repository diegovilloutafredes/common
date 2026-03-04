//
//  Separator.swift
//

import UIKit

/// A view representing a visual separator line.
public final class Separator: BaseView {
    private let color: UIColor
    private let height: Double

    /// Initializes a new separator.
    /// - Parameters:
    ///   - color: The color of the separator. Defaults to black.
    ///   - height: The height of the separator. Defaults to 1.
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
    
    /// Adds a separator below the view.
    /// - Parameters:
    ///   - color: The color of the separator.
    ///   - height: The height of the separator.
    /// - Returns: A container view wrapping self and the separator.
    @discardableResult public func addSeparator(color: UIColor = .black, height: Double = 1) -> UIView {
        addSeparator(.init(color: color, height: height))
    }

    /// Adds a separator below the view.
    /// - Parameter separator: The separator view to add.
    /// - Returns: A container view wrapping self and the separator.
    @discardableResult public func addSeparator(_ separator: Separator = .init(color: .black, height: 1)) -> UIView {
        VStack {
            self
            separator
        }
    }
}
