//
//  BaseClient.swift
//

import Foundation

// MARK: - BaseClient
open class BaseClient {
    public var requests = [String: URLSessionTask]() {
        didSet { requests.forEach { Logger.log([$0.key: $0.value]) } }
    }

    public init() {}
}

// MARK: - ClientProtocol
extension BaseClient: ClientProtocol {}
