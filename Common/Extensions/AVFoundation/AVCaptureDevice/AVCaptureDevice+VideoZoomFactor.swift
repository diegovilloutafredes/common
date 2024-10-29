//
//  AVCaptureDevice+VideoZoomFactor.swift
//

import AVFoundation

extension AVCaptureDevice {
    @discardableResult public func videoZoomFactor(_ videoZoomFactor: Double) -> Self {
        with {
            do {
                try $0.lockForConfiguration()
                $0.videoZoomFactor = videoZoomFactor
                $0.unlockForConfiguration()
            } catch {}
        }
    }
}
