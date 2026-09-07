//
//  ObservationModels.swift
//  DemoApp
//

import Common
import Observation

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
