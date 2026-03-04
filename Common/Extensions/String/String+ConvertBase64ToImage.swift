//
//  String+ConvertBase64ToImage.swift
//

import UIKit

extension String {
    
    /// Converts a Base64 encoded string to a UIImage.
    /// - Returns: The image if conversion is successful, `nil` otherwise.
    public func convertBase64StringToImage() -> UIImage? {
        guard let imageData = Data(base64Encoded: self) else { return nil }
        return .init(data: imageData)
    }
}
