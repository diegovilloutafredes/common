//
//  CircularActivityIndicatorView.swift
//

import UIKit

public final class CircularActivityIndicatorView: UIView {
    public override class var requiresConstraintBasedLayout: Bool { true }

    private let colors: [UIColor]
    private let lineWidth: CGFloat
    private let lineCap: CAShapeLayerLineCap

    public init(
        frame: CGRect,
        colors: [UIColor],
        lineWidth: CGFloat,
        lineCap: CAShapeLayerLineCap
    ) {
        self.colors = colors
        self.lineWidth = lineWidth
        self.lineCap = lineCap
        super.init(frame: frame)
        self.backgroundColor(.clear)
    }

    public convenience init(colors: [UIColor], lineWidth: CGFloat, lineCap: CAShapeLayerLineCap = .round) {
        self.init(frame: .zero, colors: colors, lineWidth: lineWidth, lineCap: lineCap)
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }
    
    private lazy var shapeLayer: ProgressShapeLayer = { .init(strokeColor: colors.first ?? .green, lineWidth: lineWidth, lineCap: lineCap) }()

    public override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.width/2

        let path = UIBezierPath(
            ovalIn: CGRect(
                x: .zero,
                y: .zero,
                width: bounds.width,
                height: bounds.height
            )
        ).cgPath

        shapeLayer.path = path
    }

    public var isAnimating: Bool = false {
        didSet {
            if isAnimating {
                animateStroke()
                animateRotation()
            } else {
                shapeLayer.removeFromSuperlayer()
                layer.removeAllAnimations()
            }
        }
    }

    @discardableResult public func animate() -> Self { with { $0.isAnimating = true } }
    @discardableResult public func stopAnimating() -> Self { with { $0.isAnimating = false } }
}

// MARK: - Animations
extension CircularActivityIndicatorView {
    private func animateStroke() {
        let startAnimation = StrokeAnimation(
            type: .start,
            beginTime: 0.25,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )

        let endAnimation = StrokeAnimation(
            type: .end,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )

        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation, endAnimation]

        shapeLayer.add(strokeAnimationGroup, forKey: nil)

        let colorAnimation = StrokeColorAnimation(
            colors: colors.map { $0.cgColor },
            duration: strokeAnimationGroup.duration * Double(colors.count)
        )

        shapeLayer.add(colorAnimation, forKey: nil)

        layer.addSublayer(shapeLayer)
    }

    private func animateRotation() {
        let rotationAnimation = RotationAnimation(
            fromValue: .zero,
            toValue: CGFloat.pi * 2,
            duration: 3,
            repeatCount: .greatestFiniteMagnitude
        )

        layer.add(rotationAnimation, forKey: nil)
    }
}
