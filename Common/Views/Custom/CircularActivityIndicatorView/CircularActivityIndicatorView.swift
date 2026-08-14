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
        setupView()
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

    // Width = height (1:1) is installed at construction time, before the first layout pass,
    // so callers that constrain only one dimension still get square bounds on the first paint.
    // `progressShapeLayer` lives on `self.layer` for the view's lifetime; only the animations
    // are added/removed by `isAnimating`. The layer is hidden when idle so no static stroke shows.
    private func setupView() {
        backgroundColor(.clear)
            .clipsToBounds(true)
            .setRatio()
        progressShapeLayer.isHidden = true
        layer.addSublayer(progressShapeLayer)
        // Core Animation strips animations when the app backgrounds, with no view
        // callback — restore them on foreground or the spinner returns as a
        // static complete ring while `isAnimating` still reads true.
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.restoreAnimationsIfNeeded() }
        }
    }

    private var foregroundObserver: (any NSObjectProtocol)?

    deinit {
        foregroundObserver.map(NotificationCenter.default.removeObserver)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        round(radius: bounds.height / 2)
        progressShapeLayer.frame = bounds
        // The stroke is centered on the path: inset by half the line width so it
        // stays inside the clipped bounds instead of rendering at half thickness.
        progressShapeLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)).cgPath
    }

    /// Layer transitions also strip animations (window removal, full-screen
    /// covers) — re-add them whenever the view becomes visible while animating.
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        restoreAnimationsIfNeeded()
    }

    /// Indicates whether the view is currently animating.
    public var isAnimating: Bool = false {
        didSet {
            if isAnimating {
                progressShapeLayer.isHidden = false
                animateStroke()
                animateRotation()
            } else {
                removeAnimations()
                progressShapeLayer.isHidden = true
            }
        }
    }

    /// Re-adds the animations Core Animation may have stripped. Re-adding resets
    /// their phase, which is meaningless for an indeterminate spinner.
    private func restoreAnimationsIfNeeded() {
        guard isAnimating, window.isNotNil else { return }
        removeAnimations()
        progressShapeLayer.isHidden = false
        animateStroke()
        animateRotation()
    }

    private func removeAnimations() {
        progressShapeLayer.removeAnimation(forKey: "stroke")
        progressShapeLayer.removeAnimation(forKey: "colour")
        layer.removeAnimation(forKey: "rotation")
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

        progressShapeLayer.add(strokeAnimationGroup, forKey: "stroke")

        let colorKeyframeAnimation = StrokeColorKeyframeAnimation(
            colors: colors.map { $0.cgColor },
            duration: strokeAnimationGroup.duration * Double(colors.count)
        )

        progressShapeLayer.add(colorKeyframeAnimation, forKey: "colour")
    }

    private func animateRotation() {
        let rotationAnimation = RotationAnimation(
            fromValue: .zero,
            toValue: CGFloat.pi * 2,
            duration: 3,
            repeatCount: .greatestFiniteMagnitude
        )

        layer.add(rotationAnimation, forKey: "rotation")
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
