//
//  ContentUpdatable.swift
//

import UIKit

// MARK: - ContentUpdatable

/// Shared scheduling for the `updateContent()` hook of the `UIView`-based bases
/// (`BaseView`, `BaseCell`, `BaseReusableView`). The conforming class keeps the stored
/// flag and the `updateProperties()` / `layoutSubviews()` overrides; the mode logic lives here.
///
/// shortcut: `BaseViewController` keeps its own copy — it schedules on `view.setNeedsLayout()` behind
/// an `isViewLoaded` guard. Upgrade path: drop the `UIView` constraint and add a `scheduleLayoutPass()`
/// requirement if the controller ever needs `updateContentIfNeeded()`.
@MainActor
protocol ContentUpdatable: UIView {

    /// Manual/unavailable-mode bookkeeping: `true` until the first pass, then only after an
    /// invalidation, so unrelated layout passes (scrolling, rotation) skip the hook.
    var needsContentUpdate: Bool { get set }

    /// Pushes state into subviews.
    func updateContent()
}

// MARK: - Default Impl
extension ContentUpdatable {

    /// Schedules `updateContent()` for the next update pass.
    func scheduleContentUpdate() {
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            setNeedsUpdateProperties()
        } else {
            needsContentUpdate = true
            setNeedsLayout()
        }
    }

    /// Runs a pending `updateContent()` now instead of waiting for the next update pass.
    func flushContentUpdateIfNeeded() {
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            updatePropertiesIfNeeded()
        } else {
            runContentUpdateIfNeeded()
        }
    }

    /// Manual/unavailable-mode pass: runs the hook under tracking when flagged (always in
    /// `.unavailable`). A no-op in `.native`, where UIKit drives `updateProperties()`.
    func runContentUpdateIfNeeded() {
        let mode = ObservationMode.current
        guard mode != .native else { return }
        guard mode == .unavailable || needsContentUpdate else { return }
        needsContentUpdate = false
        ObservationTracker.run { updateContent() } onInvalidate: { [weak self] in self?.scheduleContentUpdate() }
    }
}
