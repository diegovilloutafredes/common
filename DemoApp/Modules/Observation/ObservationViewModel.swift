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
}

// MARK: - ObservationViewProtocol
protocol ObservationViewProtocol: ScreenSizeMeasurable {
    func render(count: Int, unread: Int, mode: String)
}

// MARK: - ObservationViewModel
@MainActor
final class ObservationViewModel {
    let title = "Observation"
    let counter = CounterModel()
    let messages: [MessageItem] = [
        .init(sender: "Ana", preview: "Release notes for 1.7.0 are ready"),
        .init(sender: "Bruno", preview: "Can you review the Observation PR?"),
        .init(sender: "Camila", preview: "Lunch at 1?", isRead: true),
        .init(sender: "Diego", preview: "updateContent() replaced my didSet"),
    ]
    weak var view: ObservationViewProtocol?
}

// MARK: - ObservationViewModelProtocol
extension ObservationViewModel: ObservationViewModelProtocol {
    func increment() { counter.count += 1 }
    func reset() { counter.count = .zero }
    func markAllRead() { messages.forEach { $0.isRead = true } }
}

// MARK: - ViewLifecycleable
extension ObservationViewModel: ViewLifecycleable {
    /// Every read here is tracked: mutating `counter.count` or any `isRead` re-runs it.
    func onUpdateProperties() {
        view?.render(
            count: counter.count,
            unread: messages.filter { !$0.isRead }.count,
            mode: "\(ObservationMode.current)"
        )
    }
}

// MARK: - CollectionViewable
extension ObservationViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { messages.count }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { MessageCell.reuseIdentifier }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { messages[index] }
    func onSizeForItem(in section: Int, at index: Int) -> (width: Double, height: Double) {
        (view?.screenWidth ?? 375, MessageCell.height)
    }
    func onItemSelected(in section: Int, at index: Int) { messages[index].isRead.toggle() }
}
