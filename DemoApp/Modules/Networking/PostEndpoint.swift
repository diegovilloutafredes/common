//
//  PostEndpoint.swift
//  DemoApp
//

import Foundation
import Common

// MARK: - Post
struct Post: Storable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

// MARK: - NewPost
struct NewPost: Encodable {
    let userId: Int
    let title: String
    let body: String
}

// MARK: - PostEndpoint
enum PostEndpoint: Endpoint {
    case posts
    case create(NewPost)

    var baseURL: URL? { PostEnvironment.baseURL }
    var path: String { "/posts" }
    var method: HTTPMethod {
        switch self {
        case .posts: .get
        case .create: .post   // JSON body — Endpoint encodes parameters for POST/PUT/PATCH
        }
    }
    var headers: HTTPHeaders { [:] }
    var parameters: Encodable? {
        switch self {
        case .posts: nil
        case .create(let newPost): newPost
        }
    }
}

// MARK: - UploadEndpoint
// Multipart target: httpbin.org echoes the request back, so the demo can show
// what arrived without a real backend.
enum UploadEndpoint: Endpoint {
    case echo

    var baseURL: URL? { .init(string: "https://httpbin.org") }
    var path: String { "/post" }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders { [:] }
    var parameters: Encodable? { nil }
}

// MARK: - UploadEchoResponse
struct UploadEchoResponse: Storable {
    let url: String
}
