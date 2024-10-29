//
//  AVCaptureVideoDataOutput+AlwaysDiscardsLateVideoFrames.swift
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    @discardableResult public func alwaysDiscardsLateVideoFrames(_ alwaysDiscardsLateVideoFrames: Bool = true) -> Self {
        with { $0.alwaysDiscardsLateVideoFrames = alwaysDiscardsLateVideoFrames }
    }
}
