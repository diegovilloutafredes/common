//
//  ListsViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ListsViewController
final class ListsViewController: BaseCollectionViewableViewController<ListsViewModelProtocol> {

    private lazy var list = VList(dataSource: self, delegate: self)
        .register(ListItemCell.self)
        .register(ListSectionHeaderView.self, kind: .header)
        .register(ListSectionHeaderView.self, kind: .footer)

    /// The revision last pushed into the collection view. `updateContent()` re-runs for any
    /// tracked change (e.g. `isRefreshing`), so the reload is gated on the revision it read.
    private var renderedRevision: Int = .zero

    @UIViewBuilder
    override var mainView: UIView {
        list.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemGroupedBackground)
        list.refreshControl = UIRefreshControl()
            .onValueChanged { [weak self] in self?.viewModel.refresh() }
    }

    override func updateContent() {
        super.updateContent()
        if renderedRevision != viewModel.revision {
            renderedRevision = viewModel.revision
            list.reloadData()
        }
        if !viewModel.isRefreshing, list.refreshControl?.isRefreshing == true {
            list.refreshControl?.endRefreshing()
        }
    }
}
