//
//  PostEnvironment.swift
//  DemoApp
//

import Foundation
import Common

// MARK: - PostEnvironment
enum PostEnvironment: Environment {
    static var current: PostEnvironment = .posts
    case posts

    static var baseURLAsString: String { "https://jsonplaceholder.typicode.com" }
}
