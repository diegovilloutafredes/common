//
//  ProgressShapeLayer.swift
//

import UIKit

/// A customized `CAShapeLayer` used for the progress stroke.
final class ProgressShapeLayer: CAShapeLayer {
    
    /// Initializes a new progress shape layer.
    /// - Parameters:
    ///   - fillColor: The fill color of the layer. Defaults to clear.
    ///   - lineCap: The line cap style. Defaults to `.round`.
    ///   - lineWidth: The line width.
    ///   - strokeColor: The stroke color.
    init(
        fillColor: UIColor = .clear,
        lineCap: CAShapeLayerLineCap = .round,
        lineWidth: CGFloat,
        strokeColor: UIColor
    ) {
        super.init()
        self.fillColor = fillColor.cgColor
        self.lineCap = lineCap
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor.cgColor
    }

    /// Core Animation clones the layer through this initializer whenever it
    /// needs a presentation/render copy — e.g. when a property changes while
    /// animations are attached. Without it the clone attempt traps.
    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
