//
//  ProgressAnimationView.swift
//

import UIKit

/// A view that displays a progress animation using a gradient layer.
///
/// Each ``animate(progressColor:backgroundColor:duration:completion:)`` call owns
/// its gradient layer and its completion: starting a new animation tears the
/// previous one down (firing its completion), and the completion is delivered
/// exactly once no matter how the animation ends — including when Core Animation
/// strips it before finishing (app backgrounded, view removed from its window).
public final class ProgressAnimationView: UIView {

    /// KVC key that carries a call's identity on the animation itself —
    /// `add(_:forKey:)` copies the animation, so delegate callbacks arrive with
    /// the copy and object identity cannot be used. KVC values survive the copy.
    private static let animationTokenKey = "common.progressAnimation.token"

    /// The in-flight call: its identity and its completion. The visual layer is
    /// tracked separately so a finished gradient can stay on screen.
    private var active: (id: UUID, completion: CompletionHandler)?

    /// The gradient currently installed — animating or showing its final state.
    private var currentGradientLayer: CAGradientLayer?

    private lazy var delegateProxy = WeakAnimationDelegateProxy(target: self)

    /// Animates the progress view.
    ///
    /// Calling this while a previous animation is in flight supersedes it: the
    /// previous gradient is removed and its completion fires immediately.
    /// - Parameters:
    ///   - progressColor: The color of the progress indicator.
    ///   - backgroundColor: The background color of the view.
    ///   - duration: The duration of the animation.
    ///   - completion: A closure called exactly once when this call's animation
    ///     finishes, is stripped by Core Animation, or is superseded.
    public func animate(progressColor: CGColor, backgroundColor: CGColor, duration: CFTimeInterval, completion: CompletionHandler) {
        finishActive()
        currentGradientLayer?.removeFromSuperlayer()

        let gradientLayer = CAGradientLayer()
        let startLocations = [0, 0]
        let endLocations = [1, 1]

        gradientLayer.colors = [progressColor, backgroundColor]
        // Sublayer coordinates are relative to this view's own layer — `frame`
        // (superview coordinates) would offset the gradient by the view's origin.
        // `layoutSubviews` keeps it in sync afterwards.
        gradientLayer.frame = bounds
        gradientLayer.locations = startLocations as [NSNumber]
        gradientLayer.startPoint = .init(x: 0.0, y: 1.0)
        gradientLayer.endPoint = .init(x: 1.0, y: 1.0)

        gradientLayer.cornerRadius = 8

        layer.addSublayer(gradientLayer)
        currentGradientLayer = gradientLayer

        let id = UUID()
        active = (id, completion)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.delegate = delegateProxy
        animation.duration = duration
        animation.fromValue = startLocations
        animation.toValue = endLocations
        animation.setValue(id, forKey: Self.animationTokenKey)

        gradientLayer.locations = endLocations as [NSNumber]
        gradientLayer.add(animation, forKey: "loc")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        currentGradientLayer?.frame = bounds
    }

    /// Fires the in-flight call's completion exactly once and clears it.
    private func finishActive() {
        guard let active else { return }
        self.active = nil
        active.completion?()
    }
}

// MARK: - AnimationStopReceivable
extension ProgressAnimationView: AnimationStopReceivable {

    func animationDidStop(_ animation: CAAnimation, finished: Bool) {
        // `finished` is deliberately ignored: a stripped animation (backgrounding,
        // window removal) must not swallow the completion. Stale callbacks from a
        // superseded call carry a different token and are dropped.
        guard
            let active,
            animation.value(forKey: Self.animationTokenKey) as? UUID == active.id
        else { return }
        finishActive()
    }
}
