//
//  NetworkingViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - NetworkingViewProtocol
typealias NetworkingViewProtocol = ScreenSizeMeasurable

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

    override var viewModel: PostCellViewModel? {
        didSet {
            guard let viewModel else { return }
            titleLabel.text(viewModel.title)
            bodyLabel.text(viewModel.body)
        }
    }

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
}

// MARK: - NetworkingViewController
final class NetworkingViewController: BaseViewModelableViewController<NetworkingViewModelProtocol> {
    private lazy var list = VList(dataSource: self, delegate: self)
        .register(PostCell.self)

    private lazy var statusLabel = UILabel()
        .font(.systemFont(ofSize: 13))
        .textColor(.secondaryLabel)
        .numberOfLines(0)
        .textAlignment(.center)

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

    @UIViewBuilder
    override var mainView: UIView {
        VStack {
            VStack(
                margins: .init(top: 12, left: 16, bottom: 12, right: 16),
                spacing: 8
            ) {
                UILabel()
                    .text("GET /posts — JSONPlaceholder API")
                    .font(.monospacedSystemFont(ofSize: 12, weight: .medium))
                    .textColor(.tertiaryLabel)
                    .textAlignment(.center)
                fetchButton
                statusLabel
            }
            list
        }.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
        statusLabel.text(viewModel.statusText)
    }
}

// MARK: - NetworkingViewModelDelegate
extension NetworkingViewController: NetworkingViewModelDelegate {
    func didUpdatePosts() {
        dispatchOnMain { [weak self] in guard let self else { return }; list.reloadData() }
    }

    func didUpdateStatus() {
        dispatchOnMain { [weak self] in guard let self else { return }
            statusLabel.text(viewModel.statusText)
        }
    }

    func didFailWithError(_ message: String) {
        Snackbar.show(.init(message: "Error: \(message)"))
    }

    func didStartLoading() {
        startActivityIndicator()
    }

    func didStopLoading() {
        stopActivityIndicator()
    }
}
