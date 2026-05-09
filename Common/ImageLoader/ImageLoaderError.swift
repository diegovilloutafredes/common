import Foundation

/// Errors thrown by `ImageLoader`.
public enum ImageLoaderError: Error {
    /// The server returned a non-2xx HTTP status code.
    case badResponse(statusCode: Int)
    /// The response data could not be decoded into a `UIImage`.
    case decodingFailed
    /// The load was cancelled before a result was produced.
    case cancelled
}
