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
/// Every value carries its own identity, so assigning the same payload twice still
/// invalidates the observing controller twice. The controller consumes the slot with a
/// `ViewEventCursor` inside `updateContent()`, and the pass stays free of view-model writes.
///
/// Ceilings:
/// - The slot is last-writer-wins: two events fired between two render passes deliver only
///   the second. Screens that can burst keep an array behind a tracked `revision` instead.
/// - A controller whose view is covered (a child pushed over it) does not render; it consumes
///   the pending event when it returns on screen, not underneath the child.
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
