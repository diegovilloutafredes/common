//
//  BaseClient.swift
//

import Foundation

// MARK: - BaseClient

/// A base implementation of `ClientProtocol` that manages active requests.
open class BaseClient {

    private let requestsQueue = DispatchQueue(label: "com.common.baseclient.requests", qos: .utility)
    private var _requests = [String: URLSessionTask]()

    /// A thread-safe dictionary storing active network tasks. Logs only changed entries.
    public var requests: [String: URLSessionTask] {
        get { requestsQueue.sync { _requests } }
        set {
            var old: [String: URLSessionTask] = [:]
            requestsQueue.sync {
                old = _requests
                _requests = newValue
            }
            newValue.filter { old[$0.key] == nil }.forEach { Logger.log([$0.key: $0.value]) }
            old.filter { newValue[$0.key] == nil }.forEach { Logger.log(["removed": $0.key]) }
        }
    }

    /// Initializes a new base client.
    public init() {}
}

// MARK: - ClientProtocol
extension BaseClient: ClientProtocol {}
