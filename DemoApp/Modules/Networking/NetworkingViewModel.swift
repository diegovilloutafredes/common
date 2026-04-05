//
//  NetworkingViewModel.swift
//  DemoApp
//

import Common

// MARK: - NetworkingViewModelProtocol
protocol NetworkingViewModelProtocol: ViewModel, CollectionViewable {
    var title: String { get }
    func loadPosts()
}

// MARK: - NetworkingViewModelDelegate
protocol NetworkingViewModelDelegate: AnyObject {
    func didUpdatePosts()
    func didFailWithError(_ message: String)
    func didStartLoading()
    func didStopLoading()
}

// MARK: - NetworkingViewModel
final class NetworkingViewModel {
    let title = "Networking"
    weak var delegate: NetworkingViewModelDelegate?

    private let client = PostClient()
    private var posts: [Post] = []
    weak var view: NetworkingViewProtocol?
}

// MARK: - NetworkingViewModelProtocol
extension NetworkingViewModel: NetworkingViewModelProtocol {
    func loadPosts() {
        delegate?.didStartLoading()
        client.fetchPosts { [weak self] result in
            guard let self else { return }
            delegate?.didStopLoading()
            switch result {
            case .success(let posts):
                self.posts = posts
                delegate?.didUpdatePosts()
            case .failure(let error):
                delegate?.didFailWithError(error.localizedDescription)
            }
        }
    }
}

// MARK: - CollectionViewable
extension NetworkingViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { posts.count }

    func onCellForItem(in section: Int, at index: Int) -> ViewModel? {
        let post = posts[index]
        return PostCellViewModelImpl(title: post.title, body: post.body)
    }

    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { PostCell.reuseIdentifier }

    func onSizeForItem(in section: Int, at index: Int) -> (width: Double, height: Double) {
        (view?.screenWidth ?? 375, 80)
    }
}
