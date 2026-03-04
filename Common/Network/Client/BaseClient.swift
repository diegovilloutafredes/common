//
//  BaseClient.swift
//

import Foundation

// MARK: - BaseClient
// MARK: - BaseClient
/// A base implementation of `ClientProtocol` that manages active requests.
open class BaseClient {
    
    /// A dictionary storing active network tasks. Logs parameter changes.
    public var requests = [String: URLSessionTask]() {
        didSet { requests.forEach { Logger.log([$0.key: $0.value]) } }
    }

    /// Initializes a new base client.
    public init() {}
}

// MARK: - ClientProtocol
extension BaseClient: ClientProtocol {}
