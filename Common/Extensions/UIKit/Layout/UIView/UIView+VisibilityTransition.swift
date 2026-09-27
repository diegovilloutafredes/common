//
//  UIView+VisibilityTransition.swift
//

import UIKit

nonisolated(unsafe) private var visibilityTransitionKey: UInt8 = 0

// MARK: - VisibilityTransition
extension UIView {

    /// Bookkeeping shared by `hide(animated:)` and `show(animated:)`. Every call bumps `generation`; an animation
    /// commits its end state only while its generation is still the latest, so the last call wins.
    final class VisibilityTransition {
        var generation = 0
        /// The state the latest call asked for while its animation runs; `nil` once it has settled.
        var pendingHidden: Bool?
    }

    var visibilityTransition: VisibilityTransition {
        if let transition = objc_getAssociatedObject(self, &visibilityTransitionKey) as? VisibilityTransition { return transition }
        let transition = VisibilityTransition()
        objc_setAssociatedObject(self, &visibilityTransitionKey, transition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return transition
    }

    /// Whether the latest `hide`/`show` request, or the settled state when none is pending, is hidden.
    var isHiddenOrHiding: Bool { visibilityTransition.pendingHidden ?? isHidden }

    /// Starts a transition towards `hidden` and returns its generation.
    func beginVisibilityTransition(toHidden hidden: Bool) -> Int {
        let transition = visibilityTransition
        transition.generation += 1
        transition.pendingHidden = hidden
        return transition.generation
    }

    /// Whether `generation` is still the latest transition; if so, marks it settled.
    func settleVisibilityTransition(_ generation: Int) -> Bool {
        let transition = visibilityTransition
        guard transition.generation == generation else { return false }
        transition.pendingHidden = nil
        return true
    }
}
