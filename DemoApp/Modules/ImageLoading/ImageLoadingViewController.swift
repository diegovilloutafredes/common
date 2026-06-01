import Common
import UIKit

// MARK: - ImageLoadingViewController

final class ImageLoadingViewController: BaseCollectionViewableViewController<ImageLoadingViewModelProtocol> {

    private lazy var list = VList(dataSource: self, delegate: self)
        .register(ImageDemoCell.self)
        .register(ListSectionHeaderView.self, kind: .header)
        .with { $0.accessibilityIdentifier = "imageLoadingList" }

    @UIViewBuilder
    override var mainView: UIView {
        list.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemGroupedBackground)

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
