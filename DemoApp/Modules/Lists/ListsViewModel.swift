//
//  ListsViewModel.swift
//  DemoApp
//

import Common
import Observation
import UIKit

// MARK: - ListsViewModelProtocol
@MainActor
protocol ListsViewModelProtocol: ViewModel, CollectionViewable {
    var title: String { get }
    /// Bumped whenever the item collection changes; the controller reloads when it differs
    /// from the revision it last rendered.
    var revision: Int { get }
    var isRefreshing: Bool { get }
    /// Row taps; the controller consumes the slot with a `ViewEventCursor`.
    var event: ViewEvent<ListsViewModel.Event>? { get }
    func refresh()
}

// MARK: - ListsViewModel
@Observable
@MainActor
final class ListsViewModel {
    enum Event { case tapped(title: String) }

    let title = "Lists & Cells"
    private(set) var revision: Int = .zero
    private(set) var isRefreshing = false
    private(set) var event: ViewEvent<Event>?

    @ObservationIgnored private var items: [ListItemCellViewModelImpl] = []
    @ObservationIgnored private var nextNumber = 1

    private static let accentColors: [UIColor] = [
        .systemBlue, .systemGreen, .systemPurple,
        .systemOrange, .systemPink, .systemTeal
    ]

    init() {
        items = makeItems(from: 1, count: 15)
        nextNumber = 16
    }

    private var recentItems: [ListItemCellViewModelImpl] { Array(items.prefix(5)) }

    private func makeItems(from start: Int, count: Int) -> [ListItemCellViewModelImpl] {
        (start..<(start + count)).map { n in
            ListItemCellViewModelImpl(
                number: n,
                title: "List Item \(n)",
                subtitle: "BaseViewModelableCell — updateContent() binding",
                accentColor: ListsViewModel.accentColors[(n - 1) % ListsViewModel.accentColors.count]
            )
        }
    }
}

// MARK: - CollectionViewable
extension ListsViewModel: CollectionViewable {

    func getNumberOfSections() -> Int { 2 }

    func getNumberOfItems(in section: Int) -> Int {
        section == 0 ? recentItems.count : items.count
    }

    func onCellForItem(in section: Int, at index: Int) -> ViewModel? {
        section == 0 ? recentItems[index] : items[index]
    }

    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String {
        ListItemCell.reuseIdentifier
    }

    func onHeaderItemReuseIdentifierRequested(in section: Int) -> String {
        ListSectionHeaderView.reuseIdentifier
    }

    func onHeaderItemDataSourceRequested(in section: Int) -> ViewModel? {
        let sectionTitle = section == 0 ? "RECENT" : "ALL ITEMS (\(items.count))"
        return ListSectionHeaderViewModelImpl(title: sectionTitle)
    }

    func onSizeForItem(in section: Int, at index: Int, availableSize: Size) -> Size {
        (availableSize.width, 68)
    }

    func onSizeForHeaderItem(in section: Int, availableSize: Size) -> Size {
        (availableSize.width, 36)
    }

    // Footer supplementary — only under the last section; section 0 keeps the
    // zero default so no footer is dequeued there.
    func onFooterItemReuseIdentifierRequested(in section: Int) -> String {
        ListSectionHeaderView.reuseIdentifier
    }

    func onFooterItemDataSourceRequested(in section: Int) -> ViewModel? {
        guard section == 1 else { return nil }
        return ListSectionHeaderViewModelImpl(title: "END OF LIST — FOOTER SUPPLEMENTARY")
    }

    func onSizeForFooterItem(in section: Int, availableSize: Size) -> Size {
        section == 1 ? (availableSize.width, 32) : (.zero, .zero)
    }

    func onMinimumLineSpacingFor(section: Int) -> Double { 4 }

    func onInsetFor(section: Int) -> Inset { (top: 4, left: 0, bottom: 8, right: 0) }

    func onItemSelected(in section: Int, at index: Int) {
        let item = section == 0 ? recentItems[index] : items[index]
        event = .init(.tapped(title: item.title))
    }
}

// MARK: - ListsViewModelProtocol
extension ListsViewModel: ListsViewModelProtocol {
    /// Pull-to-refresh: the controller observes `isRefreshing` and `revision`; there is no
    /// completion closure to thread back.
    func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1.2))
            guard let self else { return }
            let fresh = makeItems(from: nextNumber, count: 6)
            items.insert(contentsOf: fresh, at: 0)
            nextNumber += 6
            revision += 1
            isRefreshing = false
        }
    }
}
