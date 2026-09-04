//
//  ObservationViewModel.swift
//  DemoApp
//

import Common

// MARK: - ObservationViewModelProtocol
@MainActor
protocol ObservationViewModelProtocol: CollectionViewable, ViewModel, ViewLifecycleable {
    var title: String { get }
    var messages: [MessageItem] { get }
    func increment()
    func reset()
    func markAllRead()
    func saveDraft()
}

// MARK: - ObservationViewProtocol
protocol ObservationViewProtocol: ScreenSizeMeasurable {
    /// The message list's width: self-sizing rows must be estimated at the list's width,
    /// not the screen's — items wider than the collection view are dropped by the layout.
    var messageListWidth: Double { get }
    func render(count: Int, unread: Int, mode: String, saves: Int)
    /// One-shot confirmation. An event, not state: it must not be re-shown by a hook re-run.
    func showDraftSaved()
}

// MARK: - ObservationViewModel
@MainActor
final class ObservationViewModel {
    let title = "Observation"
    let counter = CounterModel()
    let draft = DraftModel()
    let messages: [MessageItem] = [
        .init(sender: "Ana", preview: "Release notes for 1.7.0 are ready"),
        .init(sender: "Bruno", preview: "Can you review the Observation PR?"),
        .init(sender: "Camila", preview: "Lunch at 1?", isRead: true),
        .init(sender: "Diego", preview: "updateContent() replaced my didSet — and this row self-sizes to a longer preview, measured with its content already bound"),
    ]
    weak var view: ObservationViewProtocol?
}

// MARK: - ObservationViewModelProtocol
extension ObservationViewModel: ObservationViewModelProtocol {
    func increment() { counter.count += 1 }
    func reset() { counter.count = .zero }
    func markAllRead() { messages.forEach { $0.isRead = true } }

    /// State and event from one action: the count is observed, the confirmation is called.
    func saveDraft() {
        draft.saves += 1
        view?.showDraftSaved()
    }
}

// MARK: - ViewLifecycleable
extension ObservationViewModel: ViewLifecycleable {
    /// Every read here is tracked: mutating `counter.count` or any `isRead` re-runs it.
    func onUpdateProperties() {
        view?.render(
            count: counter.count,
            unread: messages.filter { !$0.isRead }.count,
            mode: "\(ObservationMode.current)",
            saves: draft.saves
        )
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
