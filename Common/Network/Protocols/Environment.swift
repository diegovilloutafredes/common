//
//  Environment.swift
//

import Foundation

// MARK: - Environment
public protocol Environment {
    static var current: Self { get }
    static var baseURLAsString: String { get }
    static var baseURL: URL? { get }
}

extension Environment {
    public static var baseURL: URL? { .init(string: baseURLAsString) }
}
