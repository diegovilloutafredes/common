//
//  URL+FileSize.swift
//

import Foundation

// MARK: - FileSize
extension URL {
    var fileSize: Int? {
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
}
