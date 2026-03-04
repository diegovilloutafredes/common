//
//  CircularActivityIndicatorView.swift
//

import UIKit

/// A view that displays a circular activity indicator with animated strokes.
public final class CircularActivityIndicatorView: UIView {
    public override class var requiresConstraintBasedLayout: Bool { true }

    private let colors: [UIColor]
    private let lineCap: CAShapeLayerLineCap
    private let lineWidth: CGFloat

    /// Initializes a new circular activity indicator.
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - colors: An array of colors for the indicator stroke.
    ///   - lineCap: The style for the endpoints of the stroke.
    ///   - lineWidth: The thickness of the stroke.
    public init(
        frame: CGRect,
        colors: [UIColor],
        lineCap: CAShapeLayerLineCap,
        lineWidth: CGFloat
    ) {
        self.colors = colors
        self.lineCap = lineCap
        self.lineWidth = lineWidth
        super.init(frame: frame)
        self.backgroundColor(.clear)
    }

    /// Initializes a new circular activity indicator with default frame.
    /// - Parameters:
    ///   - colors: An array of colors for the indicator stroke.
    ///   - lineCap: The style for the endpoints of the stroke. Defaults to `.butt`.
    ///   - lineWidth: The thickness of the stroke. Defaults to 4.
    public convenience init(colors: [UIColor], lineCap: CAShapeLayerLineCap = .butt, lineWidth: CGFloat = 4) {
        self.init(frame: .zero, colors: colors, lineCap: lineCap, lineWidth: lineWidth)
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    private lazy var progressShapeLayer = ProgressShapeLayer(lineCap: lineCap, lineWidth: lineWidth, strokeColor: colors.first ?? .green)

    public override func layoutSubviews() {
        super.layoutSubviews()
        setRatio()
        setAsRoundedView()

        let path = UIBezierPath(
            ovalIn: CGRect(
                x: .zero,
                y: .zero,
                width: bounds.width,
                height: bounds.height
            )
        ).cgPath
        
        progressShapeLayer.path = path
    }
    
    /// Indicates whether the view is currently animating.
    public var isAnimating: Bool = false {
        didSet {
            if isAnimating {
                animateStroke()
                animateRotation()
            } else {
                progressShapeLayer.removeFromSuperlayer()
                layer.removeAllAnimations()
            }
        }
    }
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

        progressShapeLayer.add(strokeAnimationGroup, forKey: nil)

        let colorKeyframeAnimation = StrokeColorKeyframeAnimation(
            colors: colors.map { $0.cgColor },
            duration: strokeAnimationGroup.duration * Double(colors.count)
        )

        progressShapeLayer.add(colorKeyframeAnimation, forKey: nil)

        layer.addSublayer(progressShapeLayer)
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

// MARK: - ActivityIndicatorAnimatableView
extension CircularActivityIndicatorView: ActivityIndicatorAnimatableView {
    public func startAnimating() { with { $0.isAnimating = true } }
    public func stopAnimating() { with { $0.isAnimating = false } }
}

// MARK: - Animate
extension CircularActivityIndicatorView {
    @discardableResult public func animate() -> Self {
        with { $0.startAnimating() }
    }
}
