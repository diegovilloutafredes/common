//
//  NetworkingViewModel.swift
//  DemoApp
//

import Common

// MARK: - NetworkingViewModelProtocol
protocol NetworkingViewModelProtocol: ViewModel, CollectionViewable {
    var title: String { get }
    var statusText: String { get }
    func loadPosts()
}

// MARK: - NetworkingViewModelDelegate
protocol NetworkingViewModelDelegate: AnyObject {
    func didUpdatePosts()
    func didUpdateStatus()
    func didFailWithError(_ message: String)
    func didStartLoading()
    func didStopLoading()
}

// MARK: - NetworkingViewModel
final class NetworkingViewModel {
    let title = "Networking"
    weak var delegate: NetworkingViewModelDelegate?
    private(set) var statusText = "Tap Fetch to load posts from JSONPlaceholder API"

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
            case .success(let fetchedPosts):
                posts = fetchedPosts
                statusText = "Fetched \(fetchedPosts.count) posts from API"
                delegate?.didUpdatePosts()
                delegate?.didUpdateStatus()
            case .failure(let error):
                if posts.isEmpty {
                    posts = [
                        Post(id: 1, userId: 1, title: "Mock: Getting Started", body: "API unavailable — showing sample data so the list isn't empty."),
                        Post(id: 2, userId: 1, title: "Mock: How Networking Works", body: "BaseClient sends requests via HTTPService. Endpoints define URL, method, and params.")
                    ]
                }
                statusText = "API error — showing mock data"
                delegate?.didFailWithError(error.localizedDescription)
                delegate?.didUpdatePosts()
                delegate?.didUpdateStatus()
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
        ((view?.screenWidth ?? 375) - 32, 90)
    }
}
