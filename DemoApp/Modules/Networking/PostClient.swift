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

    func createPost(_ newPost: NewPost, result: @escaping NetworkResultHandler<Post>) {
        request(from: #function, PostEndpoint.create(newPost), result: result)
    }
}

// MARK: - UploadClient
// Client style (b): calls HTTPService directly — no BaseClient subclass. This is
// the style production predominantly uses; see the guide's §10 Do's and Don'ts.
final class UploadClient {
    func uploadImage(_ imageData: Data, result: @escaping NetworkResultHandler<UploadEchoResponse>) {
        let multipart = MultipartRequest()
            .with {
                $0.add(key: "photo", fileName: "demo.png", fileMimeType: "image/png", fileData: imageData)
                $0.add(key: "source", value: "Common DemoApp")
            }
        HTTPService.upload(multipart: multipart, to: UploadEndpoint.echo, result: result)
    }
}

// MARK: - AsyncPostClient
final class AsyncPostClient: AsyncBaseClient {
    func fetchPosts() async throws -> [Post] {
        try await request(PostEndpoint.posts)
    }
}
