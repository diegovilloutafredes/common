//
//  PostUseCases.swift
//  DemoApp
//

import Common

// MARK: - PostClientProtocol

protocol PostClientProtocol: AnyObject {
    func fetchPosts(result: @escaping NetworkResultHandler<[Post]>)
}

extension PostClient: PostClientProtocol {}

// MARK: - AsyncPostClientProtocol

protocol AsyncPostClientProtocol: AnyObject {
    func fetchPosts() async throws -> [Post]
}

extension AsyncPostClient: AsyncPostClientProtocol {}

// MARK: - FetchPostsUseCase

protocol FetchPostsUseCase {
    func fetchPosts(onResult: @escaping NetworkResultHandler<[Post]>)
}

extension FetchPostsUseCase {
    func fetchPosts(onResult: @escaping NetworkResultHandler<[Post]>) {
        PostClient().fetchPosts(result: onResult)
    }
}

// MARK: - FetchPostsAsyncUseCase

protocol FetchPostsAsyncUseCase {
    func fetchPostsAsync() async throws -> [Post]
}

extension FetchPostsAsyncUseCase {
    func fetchPostsAsync() async throws -> [Post] {
        try await AsyncPostClient().fetchPosts()
    }
}
