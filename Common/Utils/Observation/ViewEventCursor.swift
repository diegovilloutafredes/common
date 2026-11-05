//
//  ViewEventCursor.swift
//

import Foundation

// MARK: - ViewEventCursor

/// Controller-side bookkeeping that acts on each `ViewEvent` exactly once.
///
/// Keep one cursor per event slot, and take the slot's event in `updateContent()`, after `super`:
///
/// ```swift
/// private var eventCursor = ViewEventCursor()
///
/// override func updateContent() {
///     super.updateContent()
///     if let event = eventCursor.take(viewModel.event) { handle(event) }
/// }
/// ```
///
/// The hook may run any number of times per change; the cursor makes acting on an event idempotent
/// without writing back to the view model. Reads made while acting are tracked like any other read in the
/// hook, so act on the payload, not on tracked state.
///
/// `take(_:ifAble:)` releases the cursor before the caller acts, so acting may render the same controller again.
/// `consume(_:_:)` runs its handler while it still holds the cursor: a handler that renders the same controller
/// synchronously reaches the cursor a second time and traps on exclusive access.
///
/// The cursor remembers the last eight events it handled and refreshes one each time a slot still holds it, so a
/// cursor shared by a few slots still acts once per firing, as long as every pass reads every slot.
public struct ViewEventCursor {

    /// How many handled events the cursor remembers.
    private static let memory = 8

    /// The ids of the events this cursor handled, the most recently seen last.
    private var handledIDs: [UUID] = []

    /// Creates a cursor that has handled nothing.
    public init() {}

    /// Returns the payload of an event the cursor hasn't handled and marks it handled.
    ///
    /// Returns `nil` for `nil`, for an event it already handled, and for any event while `ifAble` is `false`, which
    /// leaves that event pending: the first later call with `ifAble` `true` returns it. A controller under a sheet,
    /// whose own presentations would fail, passes `ifAble: presentedViewController.isNil`. The cursor schedules no
    /// pass itself: when the condition clears without a change to observed state, as when that sheet is dismissed,
    /// call `setNeedsContentUpdate()` (for example in the dismissal's completion).
    ///
    /// The cursor is released when `take` returns, so the caller can act on the payload in a way that renders the same
    /// controller again:
    ///
    /// ```swift
    /// if let event = eventCursor.take(viewModel.event, ifAble: presentedViewController.isNil) { present(event) }
    /// ```
    /// - Parameters:
    ///   - event: The view model's slot.
    ///   - ifAble: Whether the controller can act on the event in this pass.
    /// - Returns: The payload to act on, or `nil`.
    public mutating func take<Payload>(_ event: ViewEvent<Payload>?, ifAble: Bool = true) -> Payload? {
        guard let event else { return nil }
        if let index = handledIDs.firstIndex(of: event.id) {
            // A slot still holds it: keep it among the remembered events.
            handledIDs.append(handledIDs.remove(at: index))
            return nil
        }
        guard ifAble else { return nil }
        handledIDs.append(event.id)
        if handledIDs.count > Self.memory { handledIDs.removeFirst() }
        return event.payload
    }

    /// Runs `handle` once for an event the cursor has not seen; `nil` and already-handled
    /// events are ignored.
    ///
    /// `handle` runs while the cursor is still held. Prefer `take(_:ifAble:)` when acting on the event can render the
    /// same controller synchronously.
    /// - Parameters:
    ///   - event: The view model's slot.
    ///   - handle: What to do with the payload.
    public mutating func consume<Payload>(_ event: ViewEvent<Payload>?, _ handle: Handler<Payload>) {
        consume(event, ifAble: true, handle)
    }

    /// Runs `handle` once for an event the cursor has not seen, as soon as the controller can act on it.
    ///
    /// While `ifAble` is `false` the event stays pending: `handle` doesn't run and the event isn't marked consumed, so
    /// the first later pass that passes `true` handles it. A controller under a sheet, whose own presentations would
    /// fail, passes `ifAble: presentedViewController.isNil`. The cursor schedules no pass itself: when the condition
    /// clears without a change to observed state, as when that sheet is dismissed, call `setNeedsContentUpdate()`
    /// (for example in the dismissal's completion).
    ///
    /// `handle` runs while the cursor is still held. Prefer `take(_:ifAble:)` when acting on the event can render the
    /// same controller synchronously.
    /// - Parameters:
    ///   - event: The view model's slot.
    ///   - ifAble: Whether the controller can act on the event in this pass.
    ///   - handle: What to do with the payload.
    public mutating func consume<Payload>(_ event: ViewEvent<Payload>?, ifAble: Bool, _ handle: Handler<Payload>) {
        if let payload = take(event, ifAble: ifAble) { handle(payload) }
    }
}
