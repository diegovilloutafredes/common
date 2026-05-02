import UIKit

nonisolated(unsafe) private var imageTaskKey: UInt8 = 0

extension UIImageView {

    private var currentImageTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &imageTaskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &imageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Loads a remote image into this `UIImageView`.
    ///
    /// Cancels any in-flight load on this view before starting. Sets `options.placeholder`
    /// immediately. Applies `options.transition` only on network-fetched results (not cache hits).
    /// Pass a custom `loader` to override the shared instance (useful for testing).
    @discardableResult
    public func loadImage(from url: URL, options: ImageLoadOptions = .default, loader: ImageLoader = .shared) -> Self {
        currentImageTask?.cancel()
        image = options.placeholder

        let capturedSelf = self
        currentImageTask = Task { @MainActor in
            do {
                let result = try await loader.imageResult(for: url, cachePolicy: options.cachePolicy)
                guard !Task.isCancelled else { return }
                switch result.source {
                case .cache:
                    capturedSelf.image = result.image
                case .network:
                    switch options.transition {
                    case .none:
                        capturedSelf.image = result.image
                    case .fade(let duration):
                        capturedSelf.alpha = 0
                        capturedSelf.image = result.image
                        UIView.animate(withDuration: duration) { capturedSelf.alpha = 1 }
                    }
                }
                options.onCompletion?(.success(result.image))
            } catch {
                guard !Task.isCancelled, !(error is CancellationError) else { return }
                if let failureImage = options.failureImage {
                    capturedSelf.image = failureImage
                }
                options.onCompletion?(.failure(error))
            }
        }
        return self
    }

    /// Cancels any in-flight image load on this view without modifying `image`.
    public func cancelImageLoad() {
        currentImageTask?.cancel()
        currentImageTask = nil
    }
}
