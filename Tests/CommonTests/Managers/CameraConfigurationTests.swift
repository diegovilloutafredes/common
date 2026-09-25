//
//  CameraConfigurationTests.swift
//

import AVFoundation
import XCTest
@testable import Common

/// The capture-device helpers must never hand AVFoundation a value it raises on: those exceptions
/// can't be caught from Swift. There is no capture device on the simulator, so the value mapping is
/// tested as pure functions; the support guards (`isTorchModeSupported`,
/// `isAutoFocusRangeRestrictionSupported`) have no device-free test.
final class CameraConfigurationTests: XCTestCase {

    // MARK: - Zoom is clamped to the available range

    func test_zoomFactor_belowTheMinimum_givesTheMinimum() {
        XCTAssertEqual(AVCaptureDevice.clampedVideoZoomFactor(0.5, min: 1, max: 10), 1)
        XCTAssertEqual(AVCaptureDevice.clampedVideoZoomFactor(1.5, min: 2, max: 10), 2)
    }

    func test_zoomFactor_aboveTheMaximum_givesTheMaximum() {
        XCTAssertEqual(AVCaptureDevice.clampedVideoZoomFactor(20, min: 1, max: 10), 10)
    }

    func test_zoomFactor_withinRange_isKept() {
        XCTAssertEqual(AVCaptureDevice.clampedVideoZoomFactor(2.5, min: 1, max: 10), 2.5)
    }

    func test_zoomFactor_nan_givesTheMinimum() {
        XCTAssertEqual(AVCaptureDevice.clampedVideoZoomFactor(.nan, min: 1, max: 10), 1)
    }

    // MARK: - Torch level: nil means off

    func test_torchLevel_zeroOrLess_meansOff() {
        XCTAssertNil(AVCaptureDevice.normalizedTorchLevel(0))
        XCTAssertNil(AVCaptureDevice.normalizedTorchLevel(-0.5))
    }

    func test_torchLevel_nan_meansOff() {
        XCTAssertNil(AVCaptureDevice.normalizedTorchLevel(.nan), "setTorchModeOn(level:) raises on a NaN level")
    }

    func test_torchLevel_aboveOne_isCappedAtOne() {
        XCTAssertEqual(AVCaptureDevice.normalizedTorchLevel(1.5), 1)
    }

    func test_torchLevel_withinRange_isKept() {
        XCTAssertEqual(AVCaptureDevice.normalizedTorchLevel(0.25), 0.25)
    }
}
