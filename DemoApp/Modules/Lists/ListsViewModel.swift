//
//  ListsViewModel.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ListsViewModelProtocol
@MainActor
protocol ListsViewModelProtocol: ViewModel, CollectionViewable {
    var title: String { get }
    func refresh(completion: @escaping Action)
}

// MARK: - ListsViewModel
@MainActor
final class ListsViewModel {
    let title = "Lists & Cells"
    weak var view: ScreenSizeMeasurable?

    private var items: [ListItemCellViewModelImpl] = []
    private var nextNumber = 1

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
                subtitle: "BaseViewModelableCell — viewModel didSet pattern",
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

    func onSizeForItem(in section: Int, at index: Int) -> Size {
        (view?.screenWidth ?? 375, 68)
    }

    func onSizeForHeaderItem(in section: Int) -> Size {
        (view?.screenWidth ?? 375, 36)
    }

    func onMinimumLineSpacingFor(section: Int) -> Double { 4 }

    func onInsetFor(section: Int) -> Inset { (top: 4, left: 0, bottom: 8, right: 0) }

    func onItemSelected(in section: Int, at index: Int) {
        let item = section == 0 ? recentItems[index] : items[index]
        Snackbar.show(.init(message: "Tapped: \(item.title)"))
    }
}

// MARK: - ListsViewModelProtocol
extension ListsViewModel: ListsViewModelProtocol {
    func refresh(completion: @escaping Action) {
        dispatchOnMainAfter(.now() + 1.2) { [weak self] in
            guard let self else { return }
            let fresh = makeItems(from: nextNumber, count: 6)
            items.insert(contentsOf: fresh, at: 0)
            nextNumber += 6
            completion()
        }
    }
}
