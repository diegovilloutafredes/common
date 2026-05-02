import Common
import UIKit

// MARK: - ImageDemoCellViewModel

protocol ImageDemoCellViewModel: ViewModel {
    var imageURL: URL { get }
    var title: String { get }
    var subtitle: String { get }
    var badge: String? { get }
    var badgeColor: UIColor { get }
    var options: ImageLoadOptions { get }
}

final class ImageDemoCellViewModelImpl: ImageDemoCellViewModel {
    let imageURL: URL
    let title: String
    let subtitle: String
    let badge: String?
    let badgeColor: UIColor
    let options: ImageLoadOptions

    init(
        imageURL: URL,
        title: String,
        subtitle: String,
        badge: String? = nil,
        badgeColor: UIColor = .systemBlue,
        options: ImageLoadOptions = .default
    ) {
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.badgeColor = badgeColor
        self.options = options
    }
}

// MARK: - ImageDemoCell

final class ImageDemoCell: BaseViewModelableCell<ImageDemoCellViewModel> {

    private lazy var thumbView = UIImageView()
        .contentMode(.scaleAspectFill)
        .setAsRoundedView(radius: 8)
        .backgroundColor(.secondarySystemFill)
        .setConstraints { $0.set(width: 72); $0.set(height: 72) }

    private lazy var badgeLabel = UILabel()
        .font(.boldSystemFont(ofSize: 9))
        .textAlignment(.center)
        .textColor(.white)
        .numberOfLines(1)
        .round(radius: 3)
        .setConstraints { $0.set(height: 16) }

    private lazy var titleLabel = UILabel()
        .font(.boldSystemFont(ofSize: 14))
        .textColor(.label)

    private lazy var subtitleLabel = UILabel()
        .font(.systemFont(ofSize: 11))
        .textColor(.secondaryLabel)
        .numberOfLines(2)

    override var viewModel: ImageDemoCellViewModel? {
        didSet {
            guard let vm = viewModel else {
                thumbView.cancelImageLoad()
                thumbView.image = nil
                return
            }
            titleLabel.text(vm.title)
            subtitleLabel.text(vm.subtitle)

            if let badge = vm.badge {
                badgeLabel.text("  \(badge)  ")
                badgeLabel.backgroundColor(vm.badgeColor)
                badgeLabel.isHidden = false
            } else {
                badgeLabel.isHidden = true
            }

            thumbView.loadImage(from: vm.imageURL, options: vm.options)
        }
    }

    @UIViewBuilder
    override var mainView: UIView {
        HStack(
            alignment: .center,
            margins: .init(top: 10, left: 16, bottom: 10, right: 16),
            spacing: 12
        ) {
            thumbView
            VStack(spacing: 4) {
                titleLabel
                subtitleLabel
            }
            badgeLabel
        }
        .backgroundColor(.systemBackground)
        .setConstraints { $0.snap(to: $1) }
    }

    override func setupCell() {
        super.setupCell()
        backgroundColor(.clear)
    }
}
