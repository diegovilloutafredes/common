//
//  ListItemCell.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ListItemCellViewModel
protocol ListItemCellViewModel: ViewModel {
    var number: Int { get }
    var title: String { get }
    var subtitle: String { get }
    var accentColor: UIColor { get }
}

// MARK: - ListItemCellViewModelImpl
final class ListItemCellViewModelImpl: ListItemCellViewModel {
    let number: Int
    let title: String
    let subtitle: String
    let accentColor: UIColor

    init(number: Int, title: String, subtitle: String, accentColor: UIColor) {
        self.number = number
        self.title = title
        self.subtitle = subtitle
        self.accentColor = accentColor
    }
}

// MARK: - ListItemCell
final class ListItemCell: BaseViewModelableCell<ListItemCellViewModel> {
    private lazy var badge = UILabel()
        .font(.boldSystemFont(ofSize: 14))
        .textAlignment(.center)
        .textColor(.white)
        .setConstraints { $0.set(width: 36); $0.set(height: 36) }

    private lazy var titleLabel = UILabel()
        .font(.boldSystemFont(ofSize: 15))
        .textColor(.label)
        .numberOfLines(1)

    private lazy var subtitleLabel = UILabel()
        .font(.systemFont(ofSize: 12))
        .textColor(.secondaryLabel)
        .numberOfLines(1)

    override var viewModel: ListItemCellViewModel? {
        didSet {
            guard let vm = viewModel else { return }
            badge.text("\(vm.number)").backgroundColor(vm.accentColor).setAsRoundedView()
            titleLabel.text(vm.title)
            subtitleLabel.text(vm.subtitle)
        }
    }

    @UIViewBuilder
    override var mainView: UIView {
        HStack(
            alignment: .center,
            margins: .init(top: 10, left: 16, bottom: 10, right: 16),
            spacing: 12
        ) {
            badge
            VStack(spacing: 2) {
                titleLabel
                subtitleLabel
            }
        }
        .backgroundColor(.systemBackground)
        .setConstraints { $0.snap(to: $1) }
    }

    override func setupCell() {
        super.setupCell()
        backgroundColor(.clear)
    }
}
