//
//  ObservationViewModel.swift
//  DemoApp
//

import Common
import Observation

// MARK: - ObservationViewModelProtocol
@MainActor
protocol ObservationViewModelProtocol: CollectionViewable, ViewModel, ViewLifecycleable {
    var title: String { get }
    var count: Int { get }
    var saves: Int { get }
    /// Bumps when `messages` changes membership; the controller reloads the list on it.
    var revision: Int { get }
    var messages: [MessageItem] { get }
    /// Drives a constraint constant in the controller's hook (the *Constraints from state* card).
    var isBarExpanded: Bool { get }
    func increment()
    func reset()
    func markAllRead()
    func addMessage()
    func removeLastMessage()
    func toggleBar()
    func saveDraft()
}

// MARK: - ObservationViewProtocol
protocol ObservationViewProtocol: ScreenSizeMeasurable {
    /// The message list's width: self-sizing rows must be estimated at the list's width,
    /// not the screen's — items wider than the collection view are dropped by the layout.
    var messageListWidth: Double { get }
    /// Variant card only: the view-model-side hook pushes what it read. This is the one place
    /// state crosses the view protocol; every other card is rendered by the controller's `updateContent()`.
    func renderMode(_ mode: String, unread: Int)
    /// One-shot confirmation. An event, not state: it must not be re-shown by a hook re-run.
    func showDraftSaved()
}

// MARK: - ObservationViewModel
@Observable @MainActor
final class ObservationViewModel {
    let title = "Observation"
    private(set) var count: Int = .zero
    private(set) var saves: Int = .zero
    private(set) var revision: Int = .zero
    private(set) var isBarExpanded = false
    /// Not tracked: rows are reference types, so a tap mutates one item without touching the
    /// array. Membership changes bump `revision` instead (guide §5, *Collections go behind a revision*).
    @ObservationIgnored private(set) var messages: [MessageItem] = [
        .init(sender: "Ana", preview: "Release notes for 1.7.0 are ready"),
        .init(sender: "Bruno", preview: "Can you review the Observation PR?"),
        .init(sender: "Camila", preview: "Lunch at 1?", isRead: true),
        .init(sender: "Diego", preview: "updateContent() replaced my didSet — and this row self-sizes to a longer preview, measured with its content already bound"),
    ] { didSet { revision += 1 } }
    @ObservationIgnored weak var view: ObservationViewProtocol?
}

// MARK: - ObservationViewModelProtocol
extension ObservationViewModel: ObservationViewModelProtocol {
    func increment() { count += 1 }
    func reset() { count = .zero }
    func markAllRead() { messages.forEach { $0.isRead = true } }
    func addMessage() { messages.append(.init(sender: "Eva", preview: "Message #\(messages.count + 1)")) }
    func removeLastMessage() {
        guard messages.isNotEmpty else { return }
        messages.removeLast()
    }
    func toggleBar() { isBarExpanded.toggle() }

    /// State and event from one action: the count is observed, the confirmation is called.
    func saveDraft() {
        saves += 1
        view?.showDraftSaved()
    }
}

// MARK: - ViewLifecycleable
extension ObservationViewModel: ViewLifecycleable {
    /// The view-model-side variant. Runs in the same pass as the controller's `updateContent()`,
    /// so any tracked read in either re-runs both; the `isRead` reads here track every row.
    func onUpdateProperties() {
        view?.renderMode("\(ObservationMode.current)", unread: messages.filter { !$0.isRead }.count)
    }
}

// MARK: - CollectionViewable
extension ObservationViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { messages.count }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { MessageCell.reuseIdentifier }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { messages[index] }
    func onSizeForItem(in section: Int, at index: Int) -> (width: Double, height: Double) {
        (view?.messageListWidth ?? 343, MessageCell.height)   // estimate; rows self-size vertically
    }
    func onItemSelected(in section: Int, at index: Int) { messages[index].isRead.toggle() }
}
