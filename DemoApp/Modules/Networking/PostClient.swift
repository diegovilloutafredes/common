//
//  PostClient.swift
//  DemoApp
//

import Common

// MARK: - PostClient
final class PostClient: BaseClient {
    func fetchPosts(result: @escaping NetworkResultHandler<[Post]>) {
        request(from: #function, PostEndpoint.posts, result: result)
    }
}
