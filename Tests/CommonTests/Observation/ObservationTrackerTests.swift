//
//  ObservationTrackerTests.swift
//

import XCTest
@testable import Common

@available(iOS 17.0, *)
@MainActor
final class ObservationTrackerTests: XCTestCase {

    override func tearDown() {
        ObservationMode.override = nil
        super.tearDown()
    }

    func test_run_alwaysExecutesBodySynchronously() {
        for mode in [ObservationMode.native, .manual, .unavailable] {
            ObservationMode.override = mode
            var ran = false
            ObservationTracker.run { ran = true } onInvalidate: {}
            XCTAssertTrue(ran, "body must run in \(mode) mode")
        }
    }

    func test_manualMode_invalidatesAfterTrackedPropertyChanges() async {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let invalidated = expectation(description: "onInvalidate")
        var read = -1

        ObservationTracker.run { read = model.value } onInvalidate: { invalidated.fulfill() }
        XCTAssertEqual(read, .zero)

        model.value = 1
        await fulfillment(of: [invalidated], timeout: callbackDeliveryTimeout)
    }

    /// `withObservationTracking` is one-shot: a second mutation before the hook
    /// re-runs must not fire `onInvalidate` again — re-arming happens on the next pass.
    func test_manualMode_invalidateIsOneShotUntilRearmed() async {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let invalidated = expectation(description: "onInvalidate")
        invalidated.assertForOverFulfill = true

        ObservationTracker.run { _ = model.value } onInvalidate: { invalidated.fulfill() }
        model.value = 1
        model.value = 2
        await fulfillment(of: [invalidated], timeout: callbackDeliveryTimeout)
        // Give a spurious second hop time to land before the over-fulfill check runs.
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    /// A main-thread mutation must invalidate before the mutating statement returns, like
    /// UIKit's native tracking does — no async hop in the common case.
    func test_manualMode_mainThreadMutation_invalidatesSynchronously() {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        var invalidated = false

        ObservationTracker.run { _ = model.value } onInvalidate: { invalidated = true }
        model.value = 1
        XCTAssertTrue(invalidated)
    }

    func test_manualMode_backgroundMutation_invalidatesOnTheMainActor() async {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let invalidated = expectation(description: "onInvalidate on main")

        ObservationTracker.run { _ = model.value } onInvalidate: {
            XCTAssertTrue(Thread.isMainThread)
            invalidated.fulfill()
        }
        DispatchQueue.global().async { model.value = 1 }
        await fulfillment(of: [invalidated], timeout: callbackDeliveryTimeout)
    }

    func test_manualMode_untrackedPropertyDoesNotInvalidate() async {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let invalidated = expectation(description: "onInvalidate")
        invalidated.isInverted = true

        ObservationTracker.run { /* reads nothing */ } onInvalidate: { invalidated.fulfill() }
        model.value = 1
        await fulfillment(of: [invalidated], timeout: 0.5)
    }

    func test_noneAndNativeModes_doNotTrackHere() async {
        for mode in [ObservationMode.unavailable, .native] {
            ObservationMode.override = mode
            let model = ObservedCounter()
            let invalidated = expectation(description: "onInvalidate in \(mode)")
            invalidated.isInverted = true

            ObservationTracker.run { _ = model.value } onInvalidate: { invalidated.fulfill() }
            model.value = 1
            await fulfillment(of: [invalidated], timeout: 0.5)
        }
    }
}
