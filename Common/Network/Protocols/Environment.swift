//
//  Environment.swift
//

import Foundation

// MARK: - Environment
/// Defines the environment configuration for network requests.
public protocol Environment {
    
    /// The current environment instance.
    static var current: Self { get }
    
    /// The base URL as a string.
    static var baseURLAsString: String { get }
    
    /// The base URL for the environment.
    static var baseURL: URL? { get }
}

extension Environment {
    public static var baseURL: URL? { .init(string: baseURLAsString) }
}
