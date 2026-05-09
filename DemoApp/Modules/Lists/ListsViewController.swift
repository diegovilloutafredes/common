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

    @UIViewBuilder
    override var mainView: UIView {
        list.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemGroupedBackground)
        list.refreshControl = UIRefreshControl()
            .onValueChanged { [weak self] in
                self?.viewModel.refresh { [weak self] in
                    self?.list.refreshControl?.endRefreshing()
                    self?.list.reloadData()
                }
            }
    }
}
