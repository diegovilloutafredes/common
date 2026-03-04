//
//  AVCaptureVideoDataOutput+SetSampleBufferDelegate.swift
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    
    /// Sets the sample buffer delegate and dispatch queue, then returns self (chainable).
    /// - Parameters:
    ///   - delegate: The delegate to receive sample buffers.
    ///   - queue: The dispatch queue for delegate callbacks. Defaults to a queue labeled "VideoDataOutputQueue".
    @discardableResult public func setSampleBufferDelegate(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue = .init(label: "VideoDataOutputQueue")) -> Self {
        with { $0.setSampleBufferDelegate(delegate, queue: queue) }
    }
}
