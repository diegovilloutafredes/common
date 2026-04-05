//
//  DemoFeatureCell.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - DemoFeatureCellViewModel
protocol DemoFeatureCellViewModel: ViewModel {
    var title: String { get }
    var subtitle: String { get }
    var action: () -> Void { get }
}

// MARK: - DemoFeatureCellViewModelImpl
final class DemoFeatureCellViewModelImpl: DemoFeatureCellViewModel {
    let title: String
    let subtitle: String
    let action: () -> Void

    init(title: String, subtitle: String, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
}

// MARK: - DemoFeatureCell
final class DemoFeatureCell: BaseViewModelableCell<DemoFeatureCellViewModel> {
    private lazy var titleLabel = UILabel()
        .font(.boldSystemFont(ofSize: 18))
        .numberOfLines(1)
        .textColor(.label)

    private lazy var subtitleLabel = UILabel()
        .font(.systemFont(ofSize: 14))
        .numberOfLines(2)
        .textColor(.secondaryLabel)

    private lazy var arrowLabel = UILabel()
        .font(.systemFont(ofSize: 18))
        .textColor(.tertiaryLabel)
        .text("›")

    override var viewModel: DemoFeatureCellViewModel? {
        didSet {
            guard let viewModel else { return }
            titleLabel.text(viewModel.title)
            subtitleLabel.text(viewModel.subtitle)
        }
    }

    @UIViewBuilder override var mainView: UIView {
        HStack(
            alignment: .center,
            margins: .init(top: 12, left: 16, bottom: 12, right: 16),
            spacing: 12
        ) {
            VStack(spacing: 4) {
                titleLabel
                subtitleLabel
            }
            arrowLabel
        }
        .setConstraints { $0.snap(to: $1) }
    }

    override func setupCell() {
        super.setupCell()
        backgroundColor(.systemBackground)
        let separator = UIView()
            .backgroundColor(.separator)
            .setConstraints {
                $0.snapLeadBottomTrail(to: $1)
                $0.set(height: 1.0 / UIScreen.main.scale)
            }
        subviews { separator }
    }
}
