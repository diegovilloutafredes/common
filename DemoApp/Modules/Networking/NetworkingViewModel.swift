//
//  NetworkingViewModel.swift
//  DemoApp
//

import Common
import Observation

// MARK: - NetworkingMode
enum NetworkingMode { case callback, async }

// MARK: - NetworkingViewModelProtocol
@MainActor
protocol NetworkingViewModelProtocol: ViewModel, CollectionViewable {
    var title: String { get }
    var statusText: String { get }
    var mode: NetworkingMode { get }
    var isLoading: Bool { get }
    /// Bumped whenever `posts` changes; the controller reloads its list when it differs
    /// from the revision it last rendered.
    var revision: Int { get }
    /// One-shot failures; the controller consumes the slot with a `ViewEventCursor`.
    var event: ViewEvent<NetworkingViewModel.Event>? { get }
    func loadPosts()
    func createPost()
    func uploadImage(_ imageData: Data)
    func setMode(_ mode: NetworkingMode)
}

// MARK: - NetworkingViewModel
@Observable
@MainActor
final class NetworkingViewModel {
    enum Event { case failed(message: String) }

    let title = "Networking"
    private(set) var statusText = "Tap Fetch to load posts from JSONPlaceholder API"
    private(set) var mode: NetworkingMode = .callback
    private(set) var isLoading = false
    private(set) var revision: Int = .zero

    /// Ignored on purpose: the collection is exposed through `revision`, so the data-source
    /// callbacks (which UIKit tracks from the collection view's own layout on iOS 26) do
    /// not register a second dependency on every element access.
    @ObservationIgnored private var posts: [Post] = [] {
        didSet { revision += 1 }
    }
    private(set) var event: ViewEvent<Event>?
}

// MARK: - NetworkingViewModelProtocol
extension NetworkingViewModel: NetworkingViewModelProtocol {
    func setMode(_ mode: NetworkingMode) {
        guard self.mode != mode else { return }
        self.mode = mode
    }

    func loadPosts() {
        // Clear the current list first so every fetch visibly empties and repopulates,
        // making the callback vs async/await methods observable on repeated taps.
        posts = []
        statusText = "Loading via \(mode == .callback ? "callback" : "async/await")…"

        switch mode {
        case .callback: loadPostsCallback()
        case .async: loadPostsAsync()
        }
    }

    func createPost() {
        statusText = "POSTing a new post…"
        isLoading = true
        let newPost = NewPost(userId: 1, title: "Hello from Common", body: "JSON body sent via PostEndpoint.create")
        createPost(newPost) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                isLoading = false
                switch result {
                case .success(let created):
                    statusText = "Created post #\(created.id) via POST (JSON body)"
                case .failure:
                    statusText = "POST failed — offline? JSONPlaceholder echoes created posts when reachable"
                }
            }
        }
    }

    func uploadImage(_ imageData: Data) {
        statusText = "Uploading \(imageData.count) bytes as multipart…"
        isLoading = true
        uploadImage(imageData) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                isLoading = false
                switch result {
                case .success(let echo):
                    statusText = "Multipart upload echoed by \(echo.url)"
                case .failure:
                    statusText = "Upload failed — offline? httpbin.org echoes the multipart body when reachable"
                }
            }
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
        isLoading = true
        fetchPosts { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                isLoading = false
                switch result {
                case .success(let fetched):
                    posts = fetched
                    statusText = "Fetched \(fetched.count) posts via callback"
                case .failure(let error):
                    if posts.isEmpty { posts = Self.mockPosts }
                    statusText = "API error — showing mock data"
                    event = .init(.failed(message: error.localizedDescription))
                }
            }
        }
    }

    func loadPostsAsync() {
        isLoading = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let fetched = try await fetchPostsAsync()
                posts = fetched
                statusText = "Fetched \(fetched.count) posts via async/await"
                isLoading = false
            } catch {
                if posts.isEmpty { posts = Self.mockPosts }
                statusText = "API error — showing mock data"
                isLoading = false
                event = .init(.failed(message: error.localizedDescription))
            }
        }
    }
}

// MARK: - UseCase conformances
extension NetworkingViewModel: FetchPostsUseCase {}
extension NetworkingViewModel: FetchPostsAsyncUseCase {}
extension NetworkingViewModel: CreatePostUseCase {}
extension NetworkingViewModel: UploadImageUseCase {}

// MARK: - CollectionViewable
extension NetworkingViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { posts.count }

    func onCellForItem(in section: Int, at index: Int) -> ViewModel? {
        let post = posts[index]
        return PostCellViewModelImpl(title: post.title, body: post.body)
    }

    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { PostCell.reuseIdentifier }

    func onSizeForItem(in section: Int, at index: Int, availableSize: Size) -> Size {
        (availableSize.width, 90)
    }
}
