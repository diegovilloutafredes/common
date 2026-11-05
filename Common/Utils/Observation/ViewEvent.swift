//
//  ViewEvent.swift
//

import Foundation

// MARK: - ViewEvent

/// A one-shot effect (a snackbar, an error alert, "submitted") modeled as observed state.
///
/// A view model exposes an optional slot and assigns a fresh value to fire:
///
/// ```swift
/// private(set) var event: ViewEvent<Event>?
/// func saveDraft() { saves += 1; event = .init(.draftSaved) }
/// ```
///
/// Every value carries its own identity, and events are equal by it: two firings with equal payloads are different
/// events, and an event equals its copies. So each `.init(_:)` fires and invalidates the observing controller, the same
/// payload included, while assigning the slot the event it already holds doesn't notify (an `@Observable` model skips
/// an equal assignment). The controller takes the slot's event with a `ViewEventCursor` (one per slot) inside
/// `updateContent()`, and the pass stays free of view-model writes. A controller created for a view model that outlived
/// the previous one skips the event the slot still holds with `ViewEventCursor.skip(_:)`.
///
/// Ceilings:
/// - The slot is last-writer-wins: two events fired between two render passes deliver only
///   the second. Screens that can burst keep an array behind a tracked `revision` instead.
/// - A controller whose view is covered (a child pushed over it) does not render; it takes
///   the pending event when it returns on screen, not underneath the child.
/// - A controller under a sheet keeps rendering, so it would take the event underneath, where its own
///   presentations fail. `ViewEventCursor.take(_:ifAble:)` with `presentedViewController.isNil` keeps the
///   event pending until the sheet is dismissed.
///
/// shortcut: single slot, last-writer-wins; upgrade path is a queued variant consumed in order.
public struct ViewEvent<Payload> {

    /// The identity of this firing. Two events with equal payloads have different ids.
    public let id: UUID

    /// What happened.
    public let payload: Payload

    /// Creates an event with a new identity.
    /// - Parameter payload: What happened.
    public init(_ payload: Payload) {
        id = .init()
        self.payload = payload
    }
}

// MARK: - Identifiable
extension ViewEvent: Identifiable {}

// MARK: - Equatable
extension ViewEvent: Equatable {

    /// Whether two events are the same firing. Compares the `id`s only, never the payloads.
    public static func == (lhs: ViewEvent, rhs: ViewEvent) -> Bool { lhs.id == rhs.id }
}

// MARK: - Sendable
// Declared in this file: Swift accepts a generic struct's Sendable conformance only from the struct's own source file.
extension ViewEvent: Sendable where Payload: Sendable {}
