//
//  AVCaptureVideoDataOutput+SetSampleBufferDelegate.swift
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    @discardableResult public func setSampleBufferDelegate(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue = .init(label: "VideoDataOutputQueue")) -> Self {
        with { $0.setSampleBufferDelegate(delegate, queue: queue) }
    }
}
