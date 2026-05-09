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
    private var preloadTasks: [URL: Task<Void, Never>] = [:]

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
            return ImageResult(image: try await existing.value, source: .network)
        }

        // Network fetch — store task for deduplication
        let task = Task<UIImage, Error> {
            try await self.fetchAndStore(url: url)
        }
        inFlightTasks[url] = task
        defer { inFlightTasks.removeValue(forKey: url) }
        return ImageResult(image: try await task.value, source: .network)
    }

    /// Loads and returns the image for `url`, using L1 → L2 → network lookup order.
    /// Concurrent calls for the same URL share one network request.
    public func image(for url: URL, cachePolicy: CachePolicy = .default) async throws -> UIImage {
        try await imageResult(for: url, cachePolicy: cachePolicy).image
    }

    // MARK: - Preloading

    /// Fetches and caches images for `urls` in the background at utility priority.
    /// URLs already in-flight (preload or normal load) are skipped.
    /// Errors are silently discarded — preloading is best-effort.
    public func preload(urls: [URL]) {
        for url in urls {
            guard preloadTasks[url] == nil, inFlightTasks[url] == nil else { continue }
            let fetchTask = Task<UIImage, Error>(priority: .utility) {
                try await self.fetchAndStore(url: url)
            }
            inFlightTasks[url] = fetchTask
            preloadTasks[url] = Task(priority: .utility) {
                _ = try? await fetchTask.value
                self.inFlightTasks.removeValue(forKey: url)
                self.preloadTasks.removeValue(forKey: url)
            }
        }
    }

    /// Cancels all in-flight preload tasks started by `preload(urls:)`.
    public func cancelPreloads() {
        for url in preloadTasks.keys {
            preloadTasks[url]?.cancel()
            inFlightTasks.removeValue(forKey: url)
        }
        preloadTasks.removeAll()
    }

    // MARK: - Private

    private func fetchAndStore(url: URL) async throws -> UIImage {
        let (data, response) = try await session.data(from: url)

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
