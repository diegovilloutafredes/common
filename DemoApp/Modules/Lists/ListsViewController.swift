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

    /// Acts on each `viewModel.event` once, however many times the hook re-runs.
    private var eventCursor = ViewEventCursor()

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

    /// `super` reloads the list when the view model's revision moves (`RevisionTrackable`).
    override func updateContent() {
        super.updateContent()
        if !viewModel.isRefreshing, list.refreshControl?.isRefreshing == true {
            list.refreshControl?.endRefreshing()
        }
        eventCursor.consume(viewModel.event) { event in
            switch event {
            case .tapped(let title): Snackbar.show(.init(message: "Tapped: \(title)"))
            }
        }
    }
}
