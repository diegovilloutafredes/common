//
//  AVCaptureDevice+VideoZoomFactor.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the video zoom factor, clamped to the device's available range, and returns self
    /// (chainable). Outside that range AVFoundation raises an exception Swift can't catch.
    /// - Parameter videoZoomFactor: The zoom factor.
    @discardableResult public func videoZoomFactor(_ videoZoomFactor: Double) -> Self {
        with {
            do {
                try $0.lockForConfiguration()
                $0.videoZoomFactor = Self.clampedVideoZoomFactor(
                    videoZoomFactor,
                    min: $0.minAvailableVideoZoomFactor,
                    max: $0.maxAvailableVideoZoomFactor
                )
                $0.unlockForConfiguration()
            } catch {}
        }
    }

    /// `requested` limited to `lower...upper`; NaN gives `lower`.
    static func clampedVideoZoomFactor(_ requested: Double, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
        guard !requested.isNaN else { return lower }
        return Swift.min(Swift.max(CGFloat(requested), lower), upper)
    }
}
