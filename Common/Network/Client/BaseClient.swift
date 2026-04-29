//
//  BaseClient.swift
//

import Foundation

// MARK: - BaseClient

/// A base implementation of `ClientProtocol` that manages active requests.
open class BaseClient {

    /// A dictionary storing active network tasks. Logs only changed entries.
    public var requests = [String: URLSessionTask]() {
        didSet {
            requests.filter { oldValue[$0.key] == nil }.forEach { Logger.log([$0.key: $0.value]) }
            oldValue.filter { requests[$0.key] == nil }.forEach { Logger.log(["removed": $0.key]) }
        }
    }

    /// Initializes a new base client.
    public init() {}
}

// MARK: - ClientProtocol
extension BaseClient: ClientProtocol {}
