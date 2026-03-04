//
//  URL+DocumentsDirectory.swift
//

import Foundation

extension URL {
    
    /// Returns the URL to the Documents directory of the app.
    public static var documentsDirectory: URL? { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first }
}
