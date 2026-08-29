//
//  GradientView.swift
//

import UIKit

// MARK: - GradientView
/// A view that displays a color gradient using `CAGradientLayer`.
public final class GradientView: UIView {
    /// The starting color of the gradient.
    public var startColor: UIColor = .black { didSet { updateColors() }}
    /// The ending color of the gradient.
    public var endColor: UIColor = .white { didSet { updateColors() }}
    /// The starting location of the gradient.
    public var startLocation: Double = .zero { didSet { updateLocations() }}
    /// The ending location of the gradient.
    public var endLocation: Double = 0.50 { didSet { updateLocations() }}
    /// Whether the gradient is drawn horizontally.
    public var horizontalMode: Bool = false { didSet { updatePoints() }}
    /// Whether the gradient is drawn diagonally.
    public var diagonalMode: Bool = false { didSet { updatePoints() }}

    public override class var layerClass: AnyClass { CAGradientLayer.self }

    /// The underlying `CAGradientLayer`.
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    /// Initializes a new gradient view.
    /// - Parameter frame: The frame rectangle for the view.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // CGColors do not re-resolve dynamic UIColors: without this hook a
        // dark/light flip keeps the stale gradient until an incidental relayout.
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: GradientView, _: UITraitCollection) in
                self.updateColors()
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    // iOS 16 fallback — iOS 17+ uses the registered trait observation above.
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17.0),
           traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

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
        // Resolve against the view's own traits — bare `.cgColor` resolves with
        // the ambient UITraitCollection.current, which is wrong off-layout.
        gradientLayer.colors = [
            startColor.resolvedColor(with: traitCollection).cgColor,
            endColor.resolvedColor(with: traitCollection).cgColor
        ]
    }
}

// MARK: - Fluent configuration
extension GradientView {
    /// Sets both gradient colors. Dynamic colors re-resolve on interface-style changes.
    @discardableResult public func colors(startColor: UIColor, endColor: UIColor) -> Self {
        with {
            $0.startColor = startColor
            $0.endColor = endColor
        }
    }
}

extension GradientView {
    /// Runs the gradient left → right instead of top → bottom.
    @discardableResult public func horizontalMode(_ horizontalMode: Bool = true) -> Self {
        with { $0.horizontalMode = horizontalMode }
    }
}

extension GradientView {
    /// Sets where (0…1) the end color is fully reached.
    @discardableResult public func endLocation(_ endLocation: Double) -> Self {
        with { $0.endLocation = endLocation }
    }
}
