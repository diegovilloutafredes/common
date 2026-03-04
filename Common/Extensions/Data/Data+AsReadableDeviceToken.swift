//
//  Data+AsReadableDeviceToken.swift
//

import Foundation

extension Data {
    
    /// Converts the data (device token) into a readable hexadecimal string.
    public var asReadableDeviceToken: String { map { .init(format: "%02.2hhx", $0) }.joined() }
}
