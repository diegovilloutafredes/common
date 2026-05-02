import UIKit

// MARK: - CachePolicy

/// Controls whether the cache is consulted before fetching.
public enum CachePolicy: Sendable {
    /// L1 memory → L2 disk → network. Default behaviour.
    case `default`
    /// Skip L1 and L2. Always fetch from the network and update the cache on success.
    case reloadIgnoringCache
}

// MARK: - ImageLoadOptions

/// Configuration for a `UIImageView.loadImage(from:options:)` call.
public struct ImageLoadOptions: Sendable {
    /// Displayed immediately while the remote image loads.
    public var placeholder: UIImage?
    /// Displayed if the image fetch fails. If `nil`, the view retains its current image.
    public var failureImage: UIImage?
    /// Transition applied when the image is assigned. Ignored on cache hits.
    public var transition: ImageTransition
    /// Controls whether the cache is consulted before fetching. Default: `.default`.
    public var cachePolicy: CachePolicy
    /// Called on the main thread with the final result (success or failure).
    /// Not called if the load is cancelled.
    public var onCompletion: (@Sendable (Result<UIImage, Error>) -> Void)?

    public init(
        placeholder: UIImage? = nil,
        failureImage: UIImage? = nil,
        transition: ImageTransition = .none,
        cachePolicy: CachePolicy = .default,
        onCompletion: (@Sendable (Result<UIImage, Error>) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.failureImage = failureImage
        self.transition = transition
        self.cachePolicy = cachePolicy
        self.onCompletion = onCompletion
    }

    /// Default options: no placeholder, no failure image, no transition, default cache policy.
    public static let `default` = ImageLoadOptions()
}
