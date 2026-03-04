//
//  AVCaptureVideoDataOutput+AlwaysDiscardsLateVideoFrames.swift
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    
    /// Sets whether late video frames should be discarded and returns self (chainable).
    /// - Parameter alwaysDiscardsLateVideoFrames: `true` to discard late frames. Defaults to `true`.
    @discardableResult public func alwaysDiscardsLateVideoFrames(_ alwaysDiscardsLateVideoFrames: Bool = true) -> Self {
        with { $0.alwaysDiscardsLateVideoFrames = alwaysDiscardsLateVideoFrames }
    }
}
