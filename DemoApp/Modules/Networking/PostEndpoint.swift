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

// MARK: - PostEndpoint
enum PostEndpoint: Endpoint {
    case posts

    var baseURL: URL? { PostEnvironment.baseURL }
    var path: String { "/posts" }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders { [:] }
    var parameters: Encodable? { nil }
}
