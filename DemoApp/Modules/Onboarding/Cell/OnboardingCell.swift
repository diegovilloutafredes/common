//
//  OnboardingCell.swift
//

import Common
import UIKit

// MARK: - OnboardingCellViewModel
protocol OnboardingCellViewModel: ViewModel {
    var image: UIImage? { get }
    var title: String { get }
    var subtitle: String { get }
}

// MARK: - OnboardingCell
final class OnboardingCell: BaseViewModelableCell<OnboardingCellViewModel> {
    private lazy var imageView = UIImageView()
        .contentMode(.scaleAspectFit)

    private lazy var titleLabel = UILabel()
        .adjustsFontSizeToFitWidth()
        .font(.appFont(style: .bold, size: 32))
        .numberOfLines()
        .textColor()

    private lazy var subtitleLabel = UILabel()
        .adjustsFontSizeToFitWidth()
        .font(.appFont(style: .medium, size: 16))
        .numberOfLines()
        .textColor()

    override var viewModel: OnboardingCellViewModel? {
        didSet { guard let viewModel else { return }
            backgroundColor(.clear)
            imageView.image(viewModel.image)
            titleLabel.text(viewModel.title)
            subtitleLabel.text(viewModel.subtitle)
        }
    }

    @UIViewBuilder override var mainView: UIView {
        VStack(margins: .init(top: 24, left: 24, bottom: 24, right: 24)) {
            imageView
            VStack(
                alignment: .center,
                margins: .init(top: 24, left: 24, bottom: 24, right: 24),
                spacing: 16
            ) {
                titleLabel
                subtitleLabel
            }
            .backgroundColor(.white)
            .round(radius: 24)
            .setRatio(328/323)
            .shadow(
                color: .init(red: 0.282, green: 0.6, blue: 0.573, alpha: 0.3),
                offset: .init(width: .zero, height: 10),
                opacity: 1,
                radius: 15
            )
        }.setConstraints { $0.snap(to: $1) }
    }
}
