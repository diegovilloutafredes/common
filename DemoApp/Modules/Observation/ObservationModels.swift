//
//  ObservationModels.swift
//  DemoApp
//

import Common
import Observation

// MARK: - CounterModel
@Observable
final class CounterModel {
    var count: Int = .zero
}

// MARK: - DraftModel
/// State for the "State vs events" card: the saves count is tracked and rendered in the hook;
/// the "saved" confirmation is deliberately *not* stored here — it is an event.
@Observable
final class DraftModel {
    var saves: Int = .zero
}

// MARK: - MessageItem
/// One row of the demo list. Conforms to `ViewModel` so a `MessageCell` can be bound to it directly.
@Observable
final class MessageItem: ViewModel {
    let sender: String
    let preview: String
    var isRead: Bool

    init(sender: String, preview: String, isRead: Bool = false) {
        self.sender = sender
        self.preview = preview
        self.isRead = isRead
    }
}
