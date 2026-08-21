//
//  CameraViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CameraViewProtocol
protocol CameraViewProtocol: AnyObject {
    func didUpdateSessionState()
    func didUpdateFrameCount(_ count: Int)
}

// MARK: - CameraViewController
final class CameraViewController: BaseViewModelableViewController<CameraViewModelProtocol> {

    private lazy var previewView = PreviewView()
        .videoGravity(.resizeAspectFill)
        .with {
            $0.backgroundColor = .black
            $0.accessibilityIdentifier = "cameraPreview"
        }
        .round(radius: 12)
        .setConstraints { $0.set(height: 260) }

    private lazy var authStatusLabel = UILabel()
        .text(viewModel.authStatusDescription)
        .font(.systemFont(ofSize: 13))
        .textColor(.secondaryLabel)
        .numberOfLines(0)
        .textAlignment(.center)

    private lazy var frameLabel = UILabel()
        .text("No frames yet — the Simulator has no capture device, so the preview stays empty there. On a device, frames stream after Start.")
        .font(.systemFont(ofSize: 12))
        .textColor(.tertiaryLabel)
        .numberOfLines(0)
        .textAlignment(.center)

    private lazy var startStopButton = UIButton(
        configuration: .filled()
            .with {
                $0.title = "Start Camera"
                $0.baseBackgroundColor = .systemBlue
                $0.cornerStyle = .capsule
                $0.image = .init(systemName: "camera")
                $0.imagePadding = 8
            }
    )
    .onTap { [weak self] in guard let self else { return }
        viewModel.toggleSession(on: previewView)
    }
    .setConstraints { $0.set(height: 50) }

    private lazy var zoomSegment = UISegmentedControl(items: ["1x", "2x"])
        .selectSegment(at: 0)
        .onValueChanged { [weak self] index in
            self?.viewModel.set(zoomFactor: index == 0 ? 1 : 2)
        }

    private lazy var torchButton = UIButton(
        configuration: .borderless()
            .with {
                $0.title = "Toggle Torch"
                $0.image = .init(systemName: "flashlight.on.fill")
                $0.imagePadding = 6
            }
    )
    .onTap { [weak self] in self?.viewModel.toggleTorch() }

    @UIViewBuilder
    override var mainView: UIView {
        UIScrollView {
            VStack(
                margins: .init(top: 24, left: 16, bottom: 32, right: 16),
                spacing: 16
            ) {
                UILabel()
                    .text("CameraManager + PreviewView + CameraAuthorizationManager")
                    .font(.monospacedSystemFont(ofSize: 12, weight: .medium))
                    .textColor(.tertiaryLabel)
                    .numberOfLines(0)
                    .textAlignment(.center)
                previewView
                authStatusLabel
                startStopButton
                zoomSegment
                torchButton
                frameLabel
            }.setConstraints {
                $0.snap(to: $1)
                $0.setWidth(to: $1.widthAnchor)
            }
        }.setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
    }

    // Stop the session when the screen goes away — the begin/finish lifecycle
    // the guide teaches. (Start stays user-initiated so opening the screen
    // never triggers a permission prompt.)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopSession()
    }
}

// MARK: - CameraViewProtocol
extension CameraViewController: CameraViewProtocol {
    func didUpdateSessionState() {
        authStatusLabel.text(viewModel.authStatusDescription)
        startStopButton.configuration?.title = viewModel.isRunning ? "Stop Camera" : "Start Camera"
        startStopButton.configuration?.baseBackgroundColor = viewModel.isRunning ? .systemRed : .systemBlue
    }

    func didUpdateFrameCount(_ count: Int) {
        frameLabel.text("Streaming — ~\(count) frames received")
    }
}
