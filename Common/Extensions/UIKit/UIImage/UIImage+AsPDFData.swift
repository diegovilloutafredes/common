//
//  UIImage+AsPDFData.swift
//

import UIKit

extension UIImage {
    
    /// Returns the image as PDF data.
    public var asPDFData: Data {
        UIGraphicsPDFRenderer(bounds: .init(origin: .zero, size: size)).pdfData {
            $0.beginPage()
            draw(in: .init(origin: .zero, size: size))
        }
    }
}
