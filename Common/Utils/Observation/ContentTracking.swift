//
//  ContentTracking.swift
//

import Observation

// MARK: - ContentTracking

/// One view's or controller's manual-mode registration for `updateContent()` (`ObservationMode.manual`).
///
/// Each run supersedes the one before it, in two ways:
/// - Its registration schedules a pass only while it belongs to the latest run (a generation check), so a model the
///   view stopped reading can't render it again.
/// - It revokes the previous registration instead of leaving it on the models it observed. Observation has no public
///   cancel on iOS 17–18, but a registration is removed from every model it observed the first time it fires. So each
///   run reads `generation` inside the tracked body, and the next run increments it and then signals a mutation: the
///   previous registration fires once, finds itself stale, and is gone. Forced runs (`setNeedsContentUpdate()`, a
///   re-bind) no longer stack registrations on models that haven't changed.
///
/// A run nested in another tracked render doesn't read `generation`: Observation merges a nested run's reads into the
/// outer registration, and revoking it later would render the outer view again for nothing.
///
/// shortcut: a nested run's registration isn't revocable, so it stays on its models until one of them changes or is
/// released. Nested runs are cells and reusable views bound inside a hook that forces layout. Upgrade path: none on
/// iOS 17–18, which has no public cancel; the native mode (iOS 26) keeps no such registrations.
@MainActor
final class ContentTracking: Observable {

    private let registrar = ObservationRegistrar()
    private var generation: UInt = .zero

    /// Every registration callback that reached this object, stale ones included. Tells a test one registration from a
    /// thousand. Not `#if DEBUG`: the release-configuration test lane compiles the tests too.
    private(set) var callbacks: Int = .zero

    /// Runs `body` under the current mode's tracking (`ObservationTracker.run(_:onInvalidate:)`), superseding the
    /// previous run's registration.
    func run(_ body: @MainActor () -> Void, onInvalidate: @escaping @MainActor () -> Void) {
        generation &+= 1
        // Fires the previous registration if it is still armed. Its callback runs inside this call, sees the new
        // generation and returns, and Observation then removes that registration from every model it observed. The
        // increment comes first because the callback runs before any mutation body would.
        registrar.withMutation(of: self, keyPath: \.generation) {}
        let current = generation
        let isNested = ObservationTracker.isRendering
        ObservationTracker.run {
            if !isNested { registrar.access(self, keyPath: \.generation) }
            body()
        } onInvalidate: { [weak self] in
            guard let self else { return }
            callbacks += 1
            guard generation == current else { return }
            onInvalidate()
        }
    }
}
