//
//  URL+FileSize.swift
//

import Foundation

// MARK: - FileSize
// MARK: - FileSize
extension URL {
    
    /// Returns the file size in bytes.
    /// - Returns: The file size, or `nil` if it cannot be determined.
    public var fileSize: Int? {
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
}
