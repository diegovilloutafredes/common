//
//  NetworkingViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - NetworkingViewProtocol
/// Only one-shot events remain here; everything else is observable state on the view model.
protocol NetworkingViewProtocol: ScreenSizeMeasurable {
    func didFailWithError(_ message: String)
}

// MARK: - PostCellViewModel
protocol PostCellViewModel: ViewModel {
    var title: String { get }
    var body: String { get }
}

// MARK: - PostCellViewModelImpl
final class PostCellViewModelImpl: PostCellViewModel {
    let title: String
    let body: String
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}

// MARK: - PostCell
final class PostCell: BaseViewModelableCell<PostCellViewModel> {
    private lazy var titleLabel = UILabel()
        .font(.boldSystemFont(ofSize: 14))
        .numberOfLines(1)
        .textColor(.label)

    private lazy var bodyLabel = UILabel()
        .font(.systemFont(ofSize: 12))
        .numberOfLines(2)
        .textColor(.secondaryLabel)

    @UIViewBuilder override var mainView: UIView {
        VStack(margins: .init(top: 4, left: 16, bottom: 4, right: 16)) {
            VStack(
                margins: .init(top: 12, left: 14, bottom: 12, right: 14),
                spacing: 4
            ) {
                titleLabel
                bodyLabel
            }
            .backgroundColor(.secondarySystemBackground)
            .round(radius: 10)
        }
        .setConstraints { $0.snap(to: $1) }
    }

    override func setupCell() {
        super.setupCell()
        backgroundColor(.clear)
    }

    override func updateContent() {
        guard let viewModel else { return }
        titleLabel.text(viewModel.title)
        bodyLabel.text(viewModel.body)
    }
}

// MARK: - NetworkingViewController
final class NetworkingViewController: BaseCollectionViewableViewController<NetworkingViewModelProtocol> {
    private lazy var list = VList(dataSource: self, delegate: self)
        .register(PostCell.self)

    private lazy var statusLabel = UILabel()
        .font(.systemFont(ofSize: 13))
        .textColor(.secondaryLabel)
        .numberOfLines(0)
        .textAlignment(.center)

    private lazy var modeSegment = UISegmentedControl(items: ["Callback", "Async"])
        .selectSegment(at: 0)
        .onValueChanged { [weak self] index in
            self?.viewModel.setMode(index == 0 ? .callback : .async)
        }

    private lazy var fetchButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Fetch Posts"
                $0.baseBackgroundColor = .systemBlue
                $0.cornerStyle = .capsule
                $0.image = .init(systemName: "arrow.clockwise")
                $0.imagePadding = 6
            }
    )
    .onTap { [weak self] in guard let self else { return }; viewModel.loadPosts() }
    .setConstraints { $0.set(height: 44) }

    private lazy var createButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Create"
                $0.baseBackgroundColor = .systemGreen
                $0.cornerStyle = .capsule
                $0.image = .init(systemName: "plus")
                $0.imagePadding = 6
            }
    )
    .onTap { [weak self] in guard let self else { return }; viewModel.createPost() }
    .setConstraints { $0.set(height: 44) }

    private lazy var uploadButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Upload"
                $0.baseBackgroundColor = .systemOrange
                $0.cornerStyle = .capsule
                $0.image = .init(systemName: "square.and.arrow.up")
                $0.imagePadding = 6
            }
    )
    .onTap { [weak self] in guard let self else { return }
        viewModel.uploadImage(Self.makeDemoPNGData())
    }
    .setConstraints { $0.set(height: 44) }

    private var renderedRevision: Int = .zero
    private var isShowingLoading = false

    @UIViewBuilder
    override var mainView: UIView {
        VStack {
            VStack(
                margins: .init(top: 12, left: 16, bottom: 12, right: 16),
                spacing: 8
            ) {
                UILabel()
                    .text("GET + POST /posts · multipart /post — JSONPlaceholder & httpbin")
                    .font(.monospacedSystemFont(ofSize: 12, weight: .medium))
                    .textColor(.tertiaryLabel)
                    .textAlignment(.center)
                modeSegment
                fetchButton
                HStack(distribution: .fillEqually, spacing: 8) {
                    createButton
                    uploadButton
                }
                statusLabel
            }
            list
        }.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    /// A tiny generated PNG so the multipart demo has real bytes to send.
    private static func makeDemoPNGData() -> Data {
        UIGraphicsImageRenderer(size: .init(width: 8, height: 8)).image { context in
            UIColor.systemOrange.setFill()
            context.fill(.init(x: 0, y: 0, width: 8, height: 8))
        }.pngData() ?? .init()
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
    }

    /// Every read below is tracked: `statusText`, `isLoading` and `revision` changes re-run
    /// this method. The reload is gated on the revision so status-only changes never reload.
    override func updateContent() {
        super.updateContent()
        statusLabel.text(viewModel.statusText)
        setLoading(viewModel.isLoading)
        if renderedRevision != viewModel.revision {
            renderedRevision = viewModel.revision
            list.reloadData()
        }
    }

    private func setLoading(_ loading: Bool) {
        guard loading != isShowingLoading else { return }
        isShowingLoading = loading
        loading ? startActivityIndicator() : stopActivityIndicator()
    }
}

// MARK: - NetworkingViewProtocol
extension NetworkingViewController: NetworkingViewProtocol {
    func didFailWithError(_ message: String) {
        Snackbar.show(.init(message: "Error: \(message)"))
    }
}
