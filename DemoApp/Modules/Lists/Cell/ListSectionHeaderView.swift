//
//  ListSectionHeaderView.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ListSectionHeaderViewModel
protocol ListSectionHeaderViewModel: ViewModel {
    var title: String { get }
}

// MARK: - ListSectionHeaderViewModelImpl
final class ListSectionHeaderViewModelImpl: ListSectionHeaderViewModel {
    let title: String
    init(title: String) { self.title = title }
}

// MARK: - ListSectionHeaderView
final class ListSectionHeaderView: BaseViewModelableReusableView<ListSectionHeaderViewModel> {

    private lazy var titleLabel = UILabel()
        .font(.boldSystemFont(ofSize: 12))
        .textColor(.secondaryLabel)
        .text("")

    override var viewModel: ListSectionHeaderViewModel? {
        didSet { titleLabel.text(viewModel?.title ?? "") }
    }

    @UIViewBuilder
    override var mainView: UIView {
        HStack(
            alignment: .center,
            margins: .init(top: 0, left: 20, bottom: 0, right: 16),
            spacing: 0
        ) {
            titleLabel
        }
        .backgroundColor(.systemGroupedBackground)
        .setConstraints { $0.snap(to: $1) }
    }
}
