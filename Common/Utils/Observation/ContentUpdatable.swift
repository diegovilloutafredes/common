//
//  ContentUpdatable.swift
//

import UIKit

// MARK: - ContentUpdatable

/// Shared scheduling for the `updateContent()` hook of the `UIView`-based bases
/// (`BaseView`, `BaseCell`, `BaseReusableView`). The conforming class keeps the stored
/// flag and the `updateProperties()` / `layoutSubviews()` overrides; the mode logic lives here.
///
/// shortcut: `BaseViewController` keeps its own copy of this scheduling, `updateContentIfNeeded()` included: it
/// schedules on `view.setNeedsLayout()` behind an `isViewLoaded` guard. Upgrade path, once a third piece has to be
/// copied: drop the `UIView` constraint and add a `scheduleLayoutPass()` requirement.
@MainActor
protocol ContentUpdatable: UIView {

    /// Manual/unavailable-mode bookkeeping: `true` until the first pass, then only after an
    /// invalidation, so unrelated layout passes (scrolling, rotation) skip the hook.
    var needsContentUpdate: Bool { get set }

    /// The view's manual-mode registration (see `ContentTracking`).
    var contentTracking: ContentTracking { get }

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
    ///
    /// In the manual mode, while another view's or controller's tracked render is in progress, a view that isn't a cell
    /// or reusable view leaves the update scheduled: running now would merge its reads into that render's tracking. It
    /// renders in its own layout pass, which follows in the same traversal. Cells and reusable views run now anyway,
    /// because self-sizing measures them before any pass.
    func flushContentUpdateIfNeeded() {
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            updatePropertiesIfNeeded()
        } else {
            guard !ObservationTracker.isRendering || self is UICollectionReusableView else { return }
            runContentUpdateIfNeeded()
        }
    }

    /// Registers `traits` in the manual mode, where a trait change doesn't re-run `updateContent()` by itself, so that a
    /// change to one of them schedules the hook. Registers nothing in the native mode, where UIKit already re-runs a
    /// hook whose traits changed, or when `traits` is empty.
    func registerContentUpdateTraits(_ traits: [UITrait]) {
        guard traits.isNotEmpty, ObservationMode.current == .manual else { return }
        registerForTraitChanges(traits) { (self: Self, _: UITraitCollection) in self.scheduleContentUpdate() }
    }

    /// Manual/unavailable-mode pass: runs the hook under tracking when flagged (always in
    /// `.unavailable`). A no-op in `.native`, where UIKit drives `updateProperties()`.
    func runContentUpdateIfNeeded() {
        let mode = ObservationMode.current
        guard mode != .native else { return }
        guard mode == .unavailable || needsContentUpdate else { return }
        needsContentUpdate = false
        contentTracking.run { updateContent() } onInvalidate: { [weak self] in self?.scheduleContentUpdate() }
    }
}
