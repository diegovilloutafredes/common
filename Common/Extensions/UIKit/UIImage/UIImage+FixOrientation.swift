//
//  UIImage+FixOrientation.swift
//

import UIKit

extension UIImage {
    public func fixOrientation() -> UIImage? {
        guard imageOrientation != .up else { return self.copy() as? UIImage }

        guard let cgImage else { return nil }

        guard
            let colorSpace = cgImage.colorSpace,
            let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return nil }

        var transform: CGAffineTransform = .identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored: break
        @unknown default: break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right: break
        @unknown default: break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: .init(x: .zero, y: .zero, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: .init(x: .zero, y: .zero, width: size.width, height: size.height))
        }

        var rect: CGRect {
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored: .init(x: .zero, y: .zero, width: size.height, height: size.width)
            default: .init(x: .zero, y: .zero, width: size.width, height: size.height)
            }
        }

        ctx.draw(cgImage, in: rect)

        guard let newCGImage = ctx.makeImage() else { return nil }
        return .init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
