//
//  ProgressShapeLayer.swift
//

import UIKit

final class ProgressShapeLayer: CAShapeLayer {
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
