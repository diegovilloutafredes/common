//
//  ProgressShapeLayer.swift
//

import UIKit

final class ProgressShapeLayer: CAShapeLayer {
    init(
        strokeColor: UIColor,
        lineWidth: CGFloat,
        fillColor: UIColor = .clear,
        lineCap: CAShapeLayerLineCap = .round
    ) {
        super.init()
        self.strokeColor = strokeColor.cgColor
        self.lineWidth = lineWidth
        self.fillColor = fillColor.cgColor
        self.lineCap = lineCap
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
