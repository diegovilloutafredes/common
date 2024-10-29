//
//  String+ConvertBase64ToImage.swift
//

import UIKit

extension String {
    public func convertBase64StringToImage() -> UIImage? {
        guard let imageData = Data(base64Encoded: self) else { return nil }
        return .init(data: imageData)
    }
}
