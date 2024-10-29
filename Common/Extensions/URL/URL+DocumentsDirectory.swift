//
//  URL+DocumentsDirectory.swift
//

import Foundation

extension URL {
    static var documentsDirectory: URL? { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first }
}
