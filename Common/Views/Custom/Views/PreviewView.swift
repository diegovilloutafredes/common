//
//  PreviewView.swift
//

import AVFoundation
import UIKit
import Vision

// MARK: - PreviewView
public final class PreviewView: UIView {
    public override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    private var observationLayers = [CAShapeLayer]()
}

extension PreviewView {
    private var session: AVCaptureSession? {
        get { captureVideoPreviewLayer.session }
        set { captureVideoPreviewLayer.session(newValue) }
    }
}

extension PreviewView {
    @discardableResult public func session(_ session: AVCaptureSession?) -> Self {
        with { $0.session = session }
    }
}

extension PreviewView {
    @discardableResult public func videoGravity(_ videoGravity: AVLayerVideoGravity) -> Self {
        with { $0.captureVideoPreviewLayer.videoGravity(videoGravity) }
    }
}

extension PreviewView {
    @discardableResult public func videoOrientation(_ videoOrientation: AVCaptureVideoOrientation) -> Self {
        with { $0.captureVideoPreviewLayer.connection?.videoOrientation = videoOrientation }
    }
}

// MARK: - Methods
extension PreviewView {
    public func draw(_ observation: VNDetectedObjectObservation) {
        removeLayers()

        let scaling = CGAffineTransform
            .identity
            .scaledBy(x: frame.width, y: frame.height)

        let translate = CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: .zero, y: -frame.height)

        let observationRect = observation
            .boundingBox
            .applying(scaling)
            .applying(translate)

        createLayer(in: observationRect)
    }
}

// MARK: - Private Method
extension PreviewView {
    private func createLayer(in rect: CGRect) {
        let shapeLayer = CAShapeLayer()
            .with {
                $0.frame = rect
                $0.cornerRadius = .DefaultValues.View.cornerRadius
                $0.opacity = 0.75
                $0.borderColor = UIColor.red.cgColor
                $0.borderWidth = 1
            }

        observationLayers.append(shapeLayer)
        layer.insertSublayer(shapeLayer, at: 1)
    }

    private func removeLayers() {
        observationLayers.forEach { $0.removeFromSuperlayer() }
        observationLayers.removeAll()
    }
}
