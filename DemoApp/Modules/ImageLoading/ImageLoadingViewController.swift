import Common
import UIKit

// MARK: - ImageLoadingViewController

final class ImageLoadingViewController: BaseCollectionViewableViewController<ImageLoadingViewModelProtocol> {

    private lazy var list = VList(dataSource: self, delegate: self)
        .register(ImageDemoCell.self)
        .register(ListSectionHeaderView.self, kind: .header)
        .with { $0.accessibilityIdentifier = "imageLoadingList" }

    // MARK: - GIFImageView demo
    private lazy var gifImageView = GIFImageView()
        .contentMode(.scaleAspectFit)
        .setConstraints { $0.set(width: 64); $0.set(height: 64) }

    private lazy var gifBanner = HStack(
        alignment: .center,
        margins: .init(horizontal: 16, vertical: 12),
        spacing: 12
    ) {
        gifImageView
        VStack(spacing: 2) {
            UILabel("GIFImageView")
                .font(.systemFont(ofSize: 14, weight: .semibold))
                .textColor(.label)
            UILabel("on-demand frame decode · pauses off-screen")
                .font(.systemFont(ofSize: 11))
                .textColor(.tertiaryLabel)
                .numberOfLines(0)
        }
        UIView()
    }
    .backgroundColor(.secondarySystemGroupedBackground)

    @UIViewBuilder
    override var mainView: UIView {
        VStack(spacing: 0) {
            gifBanner
            list
        }
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        backgroundColor(.systemGroupedBackground)
        // A continuously-animating GIF (CADisplayLink) keeps the run loop busy and
        // interferes with XCUITest's idle detection, slowing/flaking UI tests on this
        // screen. Skip the animation under UI test — the banner itself still renders.
        if !ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            gifImageView.loadGIF(named: "sample")
        }

        let preloadButton = UIBarButtonItem(
            title: "Preload",
            style: .plain,
            target: self,
            action: #selector(preloadTapped)
        )
        let clearCacheButton = UIBarButtonItem(
            title: "Clear Cache",
            style: .plain,
            target: self,
            action: #selector(clearCacheTapped)
        )
        clearCacheButton.accessibilityIdentifier = "clearCacheButton"
        navigationItem.rightBarButtonItems = [clearCacheButton, preloadButton]
    }

    @objc private func clearCacheTapped() {
        Task { @MainActor in
            await viewModel.clearCache()
        }
    }

    @objc private func preloadTapped() {
        viewModel.preloadBatch()
    }
}

// MARK: - CollectionViewReloadable

extension ImageLoadingViewController: CollectionViewReloadable {
    func reloadData() { list.reloadData() }
}
