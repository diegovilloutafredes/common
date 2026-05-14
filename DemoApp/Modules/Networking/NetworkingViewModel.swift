//
//  NetworkingViewModel.swift
//  DemoApp
//

import Common

// MARK: - NetworkingMode
enum NetworkingMode { case callback, async }

// MARK: - NetworkingViewModelProtocol
protocol NetworkingViewModelProtocol: ViewModel, CollectionViewable {
    var title: String { get }
    var statusText: String { get }
    var mode: NetworkingMode { get }
    func loadPosts()
    func setMode(_ mode: NetworkingMode)
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
    private(set) var mode: NetworkingMode = .callback

    private let client = PostClient()
    private let asyncClient = AsyncPostClient()
    private var posts: [Post] = []
    weak var view: NetworkingViewProtocol?
}

// MARK: - NetworkingViewModelProtocol
extension NetworkingViewModel: NetworkingViewModelProtocol {
    func setMode(_ mode: NetworkingMode) {
        self.mode = mode
    }

    func loadPosts() {
        switch mode {
        case .callback: loadPostsCallback()
        case .async: loadPostsAsync()
        }
    }
}

// MARK: - Private
private extension NetworkingViewModel {
    static let mockPosts = [
        Post(id: 1, userId: 1, title: "Mock: Getting Started", body: "API unavailable — showing sample data so the list isn't empty."),
        Post(id: 2, userId: 1, title: "Mock: How Networking Works", body: "BaseClient sends requests via HTTPService. Endpoints define URL, method, and params.")
    ]

    func loadPostsCallback() {
        delegate?.didStartLoading()
        client.fetchPosts { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                delegate?.didStopLoading()
                switch result {
                case .success(let fetched):
                    posts = fetched
                    statusText = "Fetched \(fetched.count) posts via callback"
                    delegate?.didUpdatePosts()
                    delegate?.didUpdateStatus()
                case .failure(let error):
                    if posts.isEmpty { posts = Self.mockPosts }
                    statusText = "API error — showing mock data"
                    delegate?.didFailWithError(error.localizedDescription)
                    delegate?.didUpdatePosts()
                    delegate?.didUpdateStatus()
                @unknown default: break
                }
            }
        }
    }

    func loadPostsAsync() {
        delegate?.didStartLoading()
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let fetched: [Post] = try await asyncClient.fetchPosts()
                posts = fetched
                statusText = "Fetched \(fetched.count) posts via async/await"
                delegate?.didStopLoading()
                delegate?.didUpdatePosts()
                delegate?.didUpdateStatus()
            } catch {
                if posts.isEmpty { posts = Self.mockPosts }
                statusText = "API error — showing mock data"
                delegate?.didStopLoading()
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
        (view?.screenWidth ?? 375, 90)
    }
}
