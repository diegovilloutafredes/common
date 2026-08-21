//
//  CameraViewModel.swift
//  DemoApp
//

import Common
import Foundation

// MARK: - CameraViewModelProtocol
protocol CameraViewModelProtocol: ViewModel {
    var title: String { get }
    var authStatusDescription: String { get }
    var isRunning: Bool { get }
    func toggleSession(on previewView: PreviewView)
    func stopSession()
    func set(zoomFactor: Double)
    func toggleTorch()
}

// MARK: - CameraViewModelImpl
final class CameraViewModelImpl: CameraViewModelProtocol {
    let title = "Camera"
    private(set) var isRunning = false
    weak var view: CameraViewProtocol?

    private var frameCount = 0

    /// The manager is created lazily so the screen can open — and UI tests can
    /// assert it — without touching the capture stack or permission state.
    private lazy var camera = CameraManager(
        onSampleBufferHandler: { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                frameCount += 1
                // One update per ~30 frames keeps the label readable.
                if frameCount % 30 == 1 { view?.didUpdateFrameCount(frameCount) }
            }
        }
    )

    var authStatusDescription: String {
        switch CameraAuthorizationManager.currentStatus {
        case .authorized: "Camera access: authorized"
        case .denied: "Camera access: denied — enable it in Settings"
        case .notDetermined: "Camera access: not requested yet — Start will ask"
        }
    }

    func toggleSession(on previewView: PreviewView) {
        isRunning ? stopSession() : start(on: previewView)
    }

    func stopSession() {
        guard isRunning else { return }
        camera.finish()
        isRunning = false
        view?.didUpdateSessionState()
    }

    func set(zoomFactor: Double) { camera.set(zoomFactor: zoomFactor) }

    func toggleTorch() { camera.toggleTorch() }
}

// MARK: - Private
private extension CameraViewModelImpl {
    func start(on previewView: PreviewView) {
        frameCount = 0
        camera.begin(previewView) { [weak self] status in
            guard let self else { return }
            isRunning = status == .authorized
            view?.didUpdateSessionState()
        }
    }
}
