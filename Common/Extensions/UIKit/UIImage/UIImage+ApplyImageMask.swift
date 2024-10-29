//
//  UIImage+ApplyImageMask.swift
//

import UIKit

extension UIImage {
    public func applyImageMask(mask: UIImage) -> UIImage {
        UIGraphicsImageRenderer(size: mask.size).image {
            let cgContext = $0.cgContext

            // Draw original image
            let rect = CGRect(origin: .zero, size: size)
            draw(in: rect)

            // Save state to restore the clipping mask
            cgContext.saveGState()

            // Apply clipping mask accounting for CGImages drawn mirrored
            cgContext.translateBy(x: .zero, y: rect.size.height)
            cgContext.scaleBy(x: 1.0, y: -1.0);
            cgContext.clip(to: rect, mask: mask.cgImage!)

            // Fill with mask applied
            cgContext.setBlendMode(.darken)
            UIColor.black.setFill()
            cgContext.fill(rect)

            // Remove clipping mask
            cgContext.restoreGState()
        }
    }
}
