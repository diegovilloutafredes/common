//
//  AsyncBaseClient.swift
//

import Foundation

// MARK: - AsyncBaseClient
/// A base implementation of `AsyncClientProtocol` for async/await-based network clients.
///
/// Subclass this to build clients using Swift's structured concurrency.
/// Request lifecycle is managed by the caller's `Task` or SwiftUI `.task {}` modifier.
///
/// ```swift
/// final class PostClient: AsyncBaseClient {
///     func fetchPosts() async throws -> [Post] {
///         try await request(PostEndpoint.posts)
///     }
/// }
/// ```
open class AsyncBaseClient {
    public init() {}
}

// MARK: - AsyncClientProtocol
extension AsyncBaseClient: AsyncClientProtocol {}
