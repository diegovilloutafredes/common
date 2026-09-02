//
//  CameraViewModel.swift
//  DemoApp
//

import Common
import Foundation
import Observation

// MARK: - CameraViewModelProtocol
@MainActor
protocol CameraViewModelProtocol: ViewModel {
    var title: String { get }
    var authStatusDescription: String { get }
    var isRunning: Bool { get }
    /// Throttled frame counter (one update per ~30 frames) so the label stays readable and
    /// the content hook is not re-run 60 times a second.
    var displayedFrameCount: Int { get }
    func toggleSession(on previewView: PreviewView)
    func stopSession()
    func set(zoomFactor: Double)
    func toggleTorch()
}

// MARK: - CameraViewModelImpl
@Observable
@MainActor
final class CameraViewModelImpl: CameraViewModelProtocol {
    let title = "Camera"
    private(set) var isRunning = false
    private(set) var displayedFrameCount: Int = .zero

    /// Raw counter — ignored so every frame does not invalidate the screen.
    @ObservationIgnored private var frameCount = 0

    /// The manager is created lazily so the screen can open — and UI tests can
    /// assert it — without touching the capture stack or permission state.
    @ObservationIgnored private lazy var camera = CameraManager(
        onSampleBufferHandler: { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                frameCount += 1
                // Throttle BEFORE the observable write: observation fires on every assignment.
                if frameCount % 30 == 1 { displayedFrameCount = frameCount }
            }
        }
    )

    var authStatusDescription: String {
        switch CameraAuthorizationManager.currentStatus {
        case .authorized: "Camera access: authorized"
        case .denied: "Camera access: denied — enable it in Settings"
        case .notDetermined: "Camera access: not requested yet — Start will ask"
        @unknown default: "Camera access: unknown"
        }
    }

    func toggleSession(on previewView: PreviewView) {
        isRunning ? stopSession() : start(on: previewView)
    }

    func stopSession() {
        guard isRunning else { return }
        camera.finish()
        isRunning = false
    }

    func set(zoomFactor: Double) { camera.set(zoomFactor: zoomFactor) }

    func toggleTorch() { camera.toggleTorch() }
}

// MARK: - Private
private extension CameraViewModelImpl {
    func start(on previewView: PreviewView) {
        frameCount = 0
        displayedFrameCount = .zero
        camera.begin(previewView) { [weak self] status in
            Task { @MainActor [weak self] in
                guard let self else { return }
                isRunning = status == .authorized
            }
        }
    }
}
