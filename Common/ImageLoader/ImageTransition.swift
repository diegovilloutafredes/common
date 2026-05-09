import Foundation

/// Controls how an image is applied to a `UIImageView` after it is loaded.
public enum ImageTransition: Sendable {
    /// Apply the image immediately with no animation.
    case none
    /// Fade the image in over the given duration (seconds).
    case fade(TimeInterval)
}
