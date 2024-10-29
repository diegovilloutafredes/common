//
//  CameraManager.swift
//

import AVFoundation

// MARK: - CameraManager
public final class CameraManager: NSObject {


    // MARK: - DefaultValues
    public enum DefaultValues {
        public static var position: AVCaptureDevice.Position { .back }
        public static var type: CameraType { .auto }
        public static var orientation: AVCaptureVideoOrientation { .defaultValue }
        public static var zoomFactor: Double { 1 }
        public static var delayBetweenFrames: Int64 { 200 }
    }

    // MARK: - CameraType
    public enum CameraType {
        case tripleCamera
        case dualCamera
        case wideAngleCamera
        case auto
    }

    private let position: AVCaptureDevice.Position
    private let type: CameraType
    private let orientation: AVCaptureVideoOrientation
    private let zoomFactor: Double
    private let delayBetweenFrames: Int64
    private let captureDeviceHandler: Handler<AVCaptureDevice>?
    private let onSampleBufferHandler: Handler<CMSampleBuffer>

    public init(
        position: AVCaptureDevice.Position = DefaultValues.position,
        type: CameraType = DefaultValues.type,
        orientation: AVCaptureVideoOrientation = DefaultValues.orientation,
        zoomFactor: Double = DefaultValues.zoomFactor,
        delayBetweenFrames: Int64 = DefaultValues.delayBetweenFrames,
        captureDeviceHandler: Handler<AVCaptureDevice>? = nil,
        onSampleBufferHandler: @escaping Handler<CMSampleBuffer>
    ) {
        self.position = position
        self.type = type
        self.orientation = orientation
        self.zoomFactor = zoomFactor
        self.delayBetweenFrames = delayBetweenFrames
        self.captureDeviceHandler = captureDeviceHandler
        self.onSampleBufferHandler = onSampleBufferHandler
    }

    private var captureDevice: AVCaptureDevice? { resolveDevice(using: position, type: type) ?? resolveDevice(using: position) ?? resolveDevice() }
    private var captureDeviceInput: AVCaptureDeviceInput? { captureDevice.isNotNil ? try? .init(device: captureDevice!) : nil }
    private let captureSession = AVCaptureSession()
        .sessionPreset(.high)
    private lazy var captureVideoDataOutput = AVCaptureVideoDataOutput()
        .alwaysDiscardsLateVideoFrames()
        .setSampleBufferDelegate(self)
        .videoOrientation(orientation)
        .videoSettings([.init(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA])

    private lazy var sessionQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "*").\(Self.self).queue")

    private var lastFrameTime = Date.asMilliseconds
    private var currentDelay: Int64 { Date.asMilliseconds - lastFrameTime }
    private var isFrameOutputAllowed: Bool { currentDelay >= delayBetweenFrames }
}

extension CameraManager {
    public func begin(_ previewView: PreviewView, handler: Handler<AuthorizationStatus>? = nil) {
        switch CameraAuthorizationManager.currentStatus {
        case .authorized:
            sessionQueue
                .async {
                    self.setupCaptureSession()
                    self.captureSession.startRunning()

                    dispatchOnMain {
                        previewView
                            .videoGravity(.resizeAspectFill)
                            .session(self.captureSession)
                        self.configureCaptureDevice()
                        handler?(CameraAuthorizationManager.currentStatus)
                    }
                }
        case .denied:
            sessionQueue
                .async { 
                    self.captureSession.stopRunning()
                    dispatchOnMain { handler?(CameraAuthorizationManager.currentStatus) }
                }
        case .notDetermined:
            CameraAuthorizationManager.requestAuthorization { _ in self.begin(previewView, handler: handler) }
        }
    }

    public func finish() { sessionQueue.async { self.captureSession.stopRunning() } }

    public func set(zoomFactor: Double) { captureDevice?.videoZoomFactor(zoomFactor) }

    public func toggleTorch() { captureDevice?.toggleTorch() }
}

extension CameraManager {
    private func configureCaptureDevice() {
        guard let captureDevice else { return }

        captureDevice
            .exposureModeIfPossible(.continuousAutoExposure)
            .focusModeIfPossible(.continuousAutoFocus)
            .videoZoomFactor(zoomFactor)

        do {
            try captureDevice.lockForConfiguration()
            captureDeviceHandler?(captureDevice)
            captureDevice.unlockForConfiguration()
        } catch {}
    }

    private func setupCaptureSession() {
        guard let captureDeviceInput else { return }
        captureSession.addInputIfPossible(captureDeviceInput)
        captureSession.addOutputIfPossible(captureVideoDataOutput)
    }

    private func resolveDevice(using position: AVCaptureDevice.Position = .back, type: CameraType = .auto) -> AVCaptureDevice? {
        switch (position, type) {
        case (.back, .auto):
            {
                let tripleCamera = resolveDevice(type: .tripleCamera)
                let dualCamera = resolveDevice(type: .dualCamera)
                let wideAngleCamera = resolveDevice(type: .wideAngleCamera)
                return tripleCamera.isNotNil ?
                tripleCamera :
                dualCamera.isNotNil ?
                dualCamera :
                wideAngleCamera
            }()
        case (.front, .auto): .default(.builtInWideAngleCamera, for: .video, position: position)
        case (_, .wideAngleCamera): .default(.builtInWideAngleCamera, for: .video, position: position)
        case (_, .dualCamera): .default(.builtInDualCamera, for: .video, position: position)
        case (_, .tripleCamera): .default(.builtInTripleCamera, for: .video, position: position)
        default: .default(for: .video)
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isFrameOutputAllowed else { return }
        lastFrameTime = Date.asMilliseconds
        dispatchOnMain { [weak self] in guard let self else { return }; self.onSampleBufferHandler(sampleBuffer) }
    }
}

// MARK: - CameraSessionHandler
public protocol CameraSessionHandler: AnyObject {
    func beginSession()
    func finishSession()
}
