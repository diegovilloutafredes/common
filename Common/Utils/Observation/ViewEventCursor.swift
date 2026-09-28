//
//  ViewEventCursor.swift
//

import Foundation

// MARK: - ViewEventCursor

/// Controller-side bookkeeping that acts on each `ViewEvent` exactly once.
///
/// Keep one per controller and call `consume` from `updateContent()`, after `super`:
///
/// ```swift
/// private var eventCursor = ViewEventCursor()
///
/// override func updateContent() {
///     super.updateContent()
///     eventCursor.consume(viewModel.event) { [weak self] in self?.handle($0) }
/// }
/// ```
///
/// The hook may run any number of times per change; the cursor makes the handler idempotent
/// without writing back to the view model. Reads inside the handler are tracked like any
/// other read in the hook — handlers act on the payload, not on tracked state.
public struct ViewEventCursor {

    private var consumedID: UUID?

    /// Creates a cursor that has consumed nothing.
    public init() {}

    /// Runs `handle` once for an event the cursor has not seen; `nil` and already-consumed
    /// events are ignored and leave the cursor unchanged.
    /// - Parameters:
    ///   - event: The view model's slot.
    ///   - handle: What to do with the payload.
    public mutating func consume<Payload>(_ event: ViewEvent<Payload>?, _ handle: (Payload) -> Void) {
        consume(event, ifAble: true, handle)
    }

    /// Runs `handle` once for an event the cursor has not seen, as soon as the controller can act on it.
    ///
    /// While `ifAble` is `false` the event stays pending: `handle` doesn't run and the event isn't marked consumed, so
    /// the first later pass that passes `true` handles it. A controller under a sheet, whose own presentations would
    /// fail, passes `ifAble: presentedViewController == nil`. The cursor schedules no pass itself: when the condition
    /// clears without a change to observed state, as when that sheet is dismissed, call `setNeedsContentUpdate()`
    /// (for example in the dismissal's completion).
    /// - Parameters:
    ///   - event: The view model's slot.
    ///   - ifAble: Whether the controller can act on the event in this pass.
    ///   - handle: What to do with the payload.
    public mutating func consume<Payload>(_ event: ViewEvent<Payload>?, ifAble: Bool, _ handle: (Payload) -> Void) {
        guard ifAble, let event, event.id != consumedID else { return }
        consumedID = event.id
        handle(event.payload)
    }
}
