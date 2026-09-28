import UIKit

enum ImageSource { case cache, network }
struct ImageResult { let image: UIImage; let source: ImageSource }

/// Actor-based coordinator for remote image loading.
/// Cache-first: L1 (memory) → L2 (disk) → network. Deduplicates concurrent requests for the same URL.
public actor ImageLoader {

    /// The shared `ImageLoader` instance. Use this for all image fetch operations.
    public static let shared = ImageLoader()

    private let session: URLSession
    /// The two-tier cache managed by this loader. Use `cache.clearAll()` to evict all entries.
    public let cache: ImageCache
    private var inFlightTasks: [URL: Task<UIImage, Error>] = [:]
    private var preloads: [URL: Preload] = [:]

    /// A tracked preload: the fetch it registered as the URL's in-flight task, and the task that cleans up after it.
    private struct Preload {
        let fetch: Task<UIImage, Error>
        let cleanup: Task<Void, Never>
    }

    private init() {
        self.session = URLSession(configuration: .ephemeral)
        self.cache = ImageCache()
    }

    internal init(urlSession: URLSession, cache: ImageCache) {
        self.session = urlSession
        self.cache = cache
    }

    /// Loads the image for `url` and returns it along with its source (cache or network).
    /// Used internally by the `UIImageView` extension to decide whether to apply fade transitions.
    func imageResult(for url: URL, cachePolicy: CachePolicy = .default) async throws -> ImageResult {
        if cachePolicy == .default {
            // L1 memory hit
            if let cached = cache.memoryImage(for: url) {
                return ImageResult(image: cached, source: .cache)
            }

            // L2 disk hit — diskData promotes to L1 as a side effect
            if let data = await cache.diskData(for: url), let image = UIImage(data: data) {
                return ImageResult(image: image, source: .cache)
            }
        }

        // Deduplication: join existing in-flight task if present
        if let existing = inFlightTasks[url] {
            let image = try await existing.value
            // Don't deliver to a caller whose task was cancelled while waiting.
            try Task.checkCancellation()
            return ImageResult(image: image, source: .network)
        }

        // Network fetch — store task for deduplication
        let task = Task<UIImage, Error> {
            try await self.fetchAndStore(url: url)
        }
        inFlightTasks[url] = task
        // Only while the entry is still this task: newer work may have replaced it.
        defer { if inFlightTasks[url] == task { inFlightTasks.removeValue(forKey: url) } }
        let image = try await task.value
        // The fetch runs on an unstructured task, so the awaiting caller's
        // cancellation doesn't propagate into it — check before delivering.
        try Task.checkCancellation()
        return ImageResult(image: image, source: .network)
    }

    /// Loads and returns the image for `url`, using L1 → L2 → network lookup order.
    /// Concurrent calls for the same URL share one network request.
    public func image(for url: URL, cachePolicy: CachePolicy = .default) async throws -> UIImage {
        try await imageResult(for: url, cachePolicy: cachePolicy).image
    }

    // MARK: - Preloading

    /// Fetches and caches images for `urls` in the background at utility priority.
    /// URLs already in-flight (preload or normal load) are skipped, and so are cached
    /// ones: a memory hit costs nothing, and a disk hit is moved into memory without a
    /// network request. Errors are silently discarded — preloading is best-effort.
    public func preload(urls: [URL]) {
        for url in urls {
            guard preloads[url] == nil, inFlightTasks[url] == nil, cache.memoryImage(for: url) == nil else { continue }
            let fetch = Task<UIImage, Error>(priority: .utility) {
                // diskData(for:) promotes a disk hit to memory.
                if let data = await self.cache.diskData(for: url), let image = UIImage(data: data) { return image }
                return try await self.fetchAndStore(url: url)
            }
            inFlightTasks[url] = fetch
            let cleanup = Task(priority: .utility) {
                _ = try? await fetch.value
                self.finishPreload(for: url, fetch: fetch)
            }
            preloads[url] = Preload(fetch: fetch, cleanup: cleanup)
        }
    }

    /// Cancels all in-flight preload fetches started by `preload(urls:)` —
    /// nothing is stored to cache once cancelled. A concurrent normal load that
    /// joined a preloaded URL receives a cancellation error (preloading is
    /// best-effort; so is cancelling it).
    public func cancelPreloads() {
        for (url, preload) in preloads {
            preload.cleanup.cancel()
            // Cancel the underlying fetch too — cancelling only the cleanup task
            // would let the network request complete and store to cache.
            preload.fetch.cancel()
            if inFlightTasks[url] == preload.fetch { inFlightTasks.removeValue(forKey: url) }
        }
        preloads.removeAll()
    }

    /// Drops what a finished preload registered, unless newer work has replaced it: after
    /// `cancelPreloads()` a normal load may already own the URL's in-flight entry.
    private func finishPreload(for url: URL, fetch: Task<UIImage, Error>) {
        if inFlightTasks[url] == fetch { inFlightTasks.removeValue(forKey: url) }
        if preloads[url]?.fetch == fetch { preloads.removeValue(forKey: url) }
    }

    // MARK: - Test seams

    /// The in-flight fetch registered for `url`, if any.
    func inFlightTask(for url: URL) -> Task<UIImage, Error>? { inFlightTasks[url] }

    /// The preload still tracked for `url`, if any. Awaiting it waits until its cleanup has run.
    func preloadTask(for url: URL) -> Task<Void, Never>? { preloads[url]?.cleanup }

    // MARK: - Private

    private func fetchAndStore(url: URL) async throws -> UIImage {
        let (data, response) = try await session.data(from: url)
        // A cancellation that raced the response must not store to cache.
        try Task.checkCancellation()

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw ImageLoaderError.badResponse(statusCode: http.statusCode)
        }

        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.decodingFailed
        }

        let ext = fileExtension(for: response)
        cache.storeInMemory(image, for: url)
        Task.detached { [cache] in
            await cache.storeToDisk(data, for: url, extension: ext)
        }

        return image
    }

    private func fileExtension(for response: URLResponse) -> String {
        switch response.mimeType {
        case "image/jpeg": return "jpg"
        case "image/png":  return "png"
        case "image/webp": return "webp"
        default:           return "dat"
        }
    }
}
