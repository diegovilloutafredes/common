//
//  GradientView.swift
//

import UIKit

// MARK: - Class GradientView
public final class GradientView: UIView {
    var startColor: UIColor = .black { didSet { updateColors() }}
    var endColor: UIColor = .white { didSet { updateColors() }}
    var startLocation: Double = .zero { didSet { updateLocations() }}
    var endLocation: Double = 0.50 { didSet { updateLocations() }}
    var horizontalMode: Bool = false { didSet { updatePoints() }}
    var diagonalMode: Bool = false { didSet { updatePoints() }}

    public override class var layerClass: AnyClass { CAGradientLayer.self }

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
