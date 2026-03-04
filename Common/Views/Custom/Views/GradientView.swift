//
//  GradientView.swift
//

import UIKit

// MARK: - Class GradientView
/// A view that displays a color gradient using `CAGradientLayer`.
public final class GradientView: UIView {
    /// The starting color of the gradient.
    var startColor: UIColor = .black { didSet { updateColors() }}
    /// The ending color of the gradient.
    var endColor: UIColor = .white { didSet { updateColors() }}
    /// The starting location of the gradient.
    var startLocation: Double = .zero { didSet { updateLocations() }}
    /// The ending location of the gradient.
    var endLocation: Double = 0.50 { didSet { updateLocations() }}
    /// Whether the gradient is drawn horizontally.
    var horizontalMode: Bool = false { didSet { updatePoints() }}
    /// Whether the gradient is drawn diagonally.
    var diagonalMode: Bool = false { didSet { updatePoints() }}

    public override class var layerClass: AnyClass { CAGradientLayer.self }

    /// The underlying `CAGradientLayer`.
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}

extension GradientView {
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }

    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }

    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}

extension GradientView {
    @discardableResult public func colors(startColor: UIColor, endColor: UIColor) -> Self {
        with {
            $0.startColor = startColor
            $0.endColor = endColor
        }
    }
}

extension GradientView {
    @discardableResult public func horizontalMode(_ horizontalMode: Bool = true) -> Self {
        with { $0.horizontalMode = horizontalMode }
    }
}

extension GradientView {
    @discardableResult public func endLocation(_ endLocation: Double) -> Self {
        with { $0.endLocation = endLocation }
    }
}
