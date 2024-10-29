//
//  Data+AsReadableDeviceToken.swift
//

import Foundation

extension Data {
    var asReadableDeviceToken: String { map { .init(format: "%02.2hhx", $0) }.joined() }
}
