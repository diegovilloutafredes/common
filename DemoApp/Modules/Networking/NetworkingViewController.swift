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
        VStack(
            margins: .init(top: 12, left: 16, bottom: 12, right: 16),
            spacing: 4
        ) {
            titleLabel
            bodyLabel
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

// MARK: - NetworkingViewController
final class NetworkingViewController: BaseViewModelableViewController<NetworkingViewModelProtocol> {
    private lazy var list = VList(dataSource: self, delegate: self)
        .register(PostCell.self)

    private lazy var fetchButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Fetch Posts"
                $0.baseBackgroundColor = .systemBlue
                $0.cornerStyle = .capsule
            }
    ).onTap { [weak self] in
        self?.viewModel.loadPosts()
    }

    @UIViewBuilder
    override var mainView: UIView {
        UIView()
            .setConstraints { $0.snap(to: $1) }
            .with { container in
                let buttonArea = VStack(margins: .init(top: 12, left: 16, bottom: 12, right: 16)) {
                    fetchButton.setConstraints { $0.set(height: 48) }
                }
                container.subviews {
                    buttonArea
                    list
                }
                buttonArea.setConstraints { $0.snapLeadTopTrail(to: $1) }
                list.setConstraints { v, sv in
                    NSLayoutConstraint.activate([
                        v.topAnchor.constraint(equalTo: buttonArea.bottomAnchor),
                        v.leadingAnchor.constraint(equalTo: sv.leadingAnchor),
                        v.trailingAnchor.constraint(equalTo: sv.trailingAnchor),
                        v.bottomAnchor.constraint(equalTo: sv.bottomAnchor)
                    ])
                }
            }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
        (viewModel as? NetworkingViewModel)?.delegate = self
        (viewModel as? NetworkingViewModel)?.view = self
    }
}

// MARK: - NetworkingViewModelDelegate
extension NetworkingViewController: NetworkingViewModelDelegate {
    func didUpdatePosts() {
        dispatchOnMain { [weak self] in
            self?.list.reloadData()
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
