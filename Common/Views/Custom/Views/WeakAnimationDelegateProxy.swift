//
//  WeakAnimationDelegateProxy.swift
//

import UIKit

// MARK: - AnimationStopReceivable

/// A target that receives forwarded `CAAnimationDelegate` stop callbacks.
@MainActor
protocol AnimationStopReceivable: AnyObject {

    /// Called when a delegated animation stops — whether it finished or was removed.
    func animationDidStop(_ animation: CAAnimation, finished: Bool)
}

// MARK: - WeakAnimationDelegateProxy

/// Forwards `CAAnimationDelegate` stop callbacks to a target without retaining it.
///
/// `CAAnimation.delegate` is a strong reference, so a view acting as its own
/// animation delegate creates a `view → layer → animation → view` cycle that
/// lasts as long as the animation stays on the layer — permanently, if the
/// animation never runs (a layer that never joins the render tree). With the
/// proxy the view can deallocate normally; the animation then releases the proxy.
final class WeakAnimationDelegateProxy: NSObject, CAAnimationDelegate {

    private weak var target: (any AnimationStopReceivable)?

    init(target: any AnimationStopReceivable) {
        self.target = target
        super.init()
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // CAAnimationDelegate stop callbacks are delivered on the main thread;
        // assert that to the type system so the MainActor-isolated target access
        // is sound (crashes, rather than corrupts, if delivered off-main).
        MainActor.assumeIsolated {
            target?.animationDidStop(anim, finished: flag)
        }
    }
}
